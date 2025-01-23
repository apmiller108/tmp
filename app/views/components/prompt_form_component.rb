# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  ID = 'prompt-form'

  attr_reader :conversation, :generate_text_request

  delegate :generate_text_requests, to: :conversation

  def initialize(conversation:, **opts)
    @opts = opts
    @conversation = conversation
    @generate_text_request = conversation.generate_text_requests.new(default_values)
  end

  def id
    ID
  end

  def disabled?
    @opts[:disabled]
  end

  def preset_options
    presets.map { |p| [p.name, p.id] }
  end

  def preset_json
    presets.map do |p|
      { id: p.id, temperature: p.temperature.to_s }
    end.to_json
  end

  def after_create_preset_redirect_path
    if conversation.persisted?
      edit_user_conversation_path(current_user, conversation)
    else
      new_user_conversation_path(current_user)
    end
  end

  private

  def last_used_options
    request = @opts.fetch(:last_request, generate_text_requests.last)

    if request
      {
        model: request.model.api_name,
        **request.slice(:temperature, :generate_text_preset_id)
      }
    else
      {}
    end
  end

  def default_values
    { model: current_user.setting.text_model, user: current_user }.merge(last_used_options)
  end

  def presets
    @presets ||= GenerateTextPreset.for_user_options(current_user.id)
  end
end
