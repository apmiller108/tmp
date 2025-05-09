class LlmTool < ApplicationRecord
<<<<<<< HEAD
=======
  enum :tool_type, {
    image: 'image'
  }
  validates :tool_type, inclusion: { in: tool_types.values, message: "%<value>s must be one of #{tool_types.values}" }

  has_many :conversation_llm_tools, dependent: :destroy

>>>>>>> 2ab5e3b (Adds llm tool type)
  before_validation :parse_input_schema

  # Must match the regex ^[a-zA-Z0-9_-]{1,64}$ for Anthropic to accept the request
  normalizes :name, with: ->(name) { name.gsub(/\s+/, '_').camelize }

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :input_schema, presence: true

  validate :validate_input_schema

  scope :active, -> { where(active: true) }

  # Finds and instantiates the appropriate handler for a given LLM tool input
  #
  # @param tool_input [Hash] The LLM tool input content block
  # @option tool_input [String] 'name' The name of the tool to handle
  # @option tool_input [Hash] 'input' The input parameters for the tool
  #
  # @example
  #   tool_input = {
  #     "id" => "toolu_01MdQEyXJfvM5hUpabMKKwMU",
  #     "name" => "GenerateImage",
  #     "type" => "tool_use",
  #     "input" => { "prompt" => "A sunset over mountains" }
  #   }
  #   handler = LlmTool.handler_for(tool_input)
  #
  # @raise [ActiveRecord::RecordNotFound] If the active tool is not found
  # @return [LlmTool::Handlers::Base] An instance of the appropriate handler class
  def self.handler_for(tool_input)
    tool = active.find_by!(name: tool_input.fetch('name'))
    tool.handler_class.new(tool_input.fetch('input'))
  end

  def handler_class
    "LlmTool::Handlers::#{name}".constantize
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
