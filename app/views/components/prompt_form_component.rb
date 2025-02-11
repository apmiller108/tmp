# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  ID = 'prompt-form'

  attr_reader :conversation_form, :generate_text_request, :turn

  delegate :conversation, :model, to: :conversation_form
  delegate :generate_text_requests, to: :conversation

  def initialize(conversation_form:, **opts)
    @conversation_form = conversation_form
    @opts = opts
    conversation_form.assign_attributes(last_used_options)
  end

  def id
    ID
  end

  def disabled?
    @opts[:disabled]
  end

  def file_input_disabled?
    GenerativeText::MODELS.find { _1.api_name == model }.capabilities.image?
  end

  def max_file_size
    GenerateTextRequest::MAX_FILE_SIZE
  end

  def file_types
    GenerateTextRequest::SUPPORTED_MIME_TYPES
  end

  def preset_options
    presets.map { |p| [p.name, p.id] }
  end

  def preset_data
    presets.map do |p|
      { id: p.id, temperature: p.temperature.to_s }
    end.to_json
  end

  def model_options
    GenerativeText::MODELS.sort_by(&:vendor).map { |m| [m.name, m.api_name] }
  end

  def model_data
    GenerativeText::MODELS.to_json(only: [:api_name, :capabilities, :image?])
  end

  def after_create_preset_redirect_path
    if conversation.persisted?
      edit_conversation_path(conversation)
    else
      new_conversation_path
    end
  end

  private

  def last_used_options
    request = generate_text_requests.last

    if request
      {
        model: request.model.api_name,
        **request.slice(:temperature, :generate_text_preset_id)
      }
    else
      {}
    end
  end

  def presets
    @presets ||= GenerateTextPreset.for_user_options(current_user.id)
  end
end
