# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  attr_reader :conversation, :generate_text_request

  delegate :generate_text_requests, to: :conversation

  def initialize(conversation:, **opts)
    @conversation = conversation
    @generate_text_request = conversation.generate_text_requests.new(default_values)
    @opts = opts
  end

  def id
    'prompt-form'
  end

  def show_options?
    @opts[:show_options]
  end

  def disabled?
    @opts[:disabled]
  end

  def preset_options
    GenerateTextPreset.for_user_options(current_user.id).pluck(:name, :id)
  end

  def after_create_preset_redirect_path
    if conversation.persisted?
      user_conversation_path(current_user, conversation)
    else
      new_user_conversation_path(current_user)
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

  def default_values
    { model: current_user.setting.text_model, user: current_user }.merge(last_used_options)
  end
end
