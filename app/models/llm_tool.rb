# app/models/llm_tool.rb
class LlmTool < ApplicationRecord
  before_validation :parse_input_schema

  # Must match the regex ^[a-zA-Z0-9_-]{1,64}$ for Anthropic to accept the request
  normalizes :name, with: ->(name) { name.gsub(/\s+/, '_').camelize }

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :input_schema, presence: true

  validate :validate_input_schema

  scope :active, -> { where(active: true) }

  def self.names
    @names ||= pluck(:name)
  end

  # @param tool_input [Hash] hash matching LLM tool input content block
  # Example:
  # { "id" => "toolu_01MdQEyXJfvM5hUpabMKKwMU",
  #   "name"=>"GenerateImage",
  #   "type"=>"tool_use",
  #   "input"=>{ "tool_use_input_json" => "here" }
  def self.handler_for(tool_input)
    name = tool_input.fetch('name')
    raise "Unknown LLM tool: #{name}" unless name.in?(names)

    "LlmTool::Handlers::#{name}".constantize.new(tool_input.fetch('input'))
  end

  def as_json
    {
      name:,
      description:,
      input_schema:
    }
  end

  private

  def validate_input_schema
    # Basic validation that it's proper JSON Schema
    unless input_schema.key?('properties') && input_schema.key?('type')
      errors.add(:input_schema, 'must be a valid JSON Schema')
    end
  end

  def parse_input_schema
    self.input_schema = JSON.parse(input_schema)
  rescue JSON::ParserError
    self.input_schema = {}
  end
end
