# app/models/llm_tool.rb
class LlmTool < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :input_schema, presence: true

  validate :validate_input_schema

  scope :active, -> { where(active: true) }

  def self.handler_mapping
    {
      # 'generate image' => 'LlmTool::Handlers::GenerateImage',
    }
  end

  def handler
    self.class.handler_mapping[name].constantize
  end

  def as_function_definition
    {
      name:,
      description:,
      input_schema:
    }
  end

  private

  def validate_input_schema
    # Basic validation that it's proper JSON Schema
    schema = JSON.parse(input_schema)
    unless schema.key?('properties') && schema.key?('type')
      errors.add(:input_schema, 'must be a valid JSON Schema')
    end
  rescue JSON::ParserError
    errors.add(:input_schema, 'must be a valid JSON Schema')
  end
end
