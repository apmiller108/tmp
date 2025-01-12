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

  private

  def last_used_options
    request = generate_text_requests.completed.last || generate_text_requests.in_progress.last

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
