# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  attr_reader :conversation, :generate_text_request

  def initialize(conversation:, **opts)
    @conversation = conversation
    @generate_text_request = conversation.generate_text_requests.new(user: current_user, model:)
    @opts = opts
  end

  def show_options?
    @opts[:show_options]
  end

  def disabled?
    @opts[:disabled]
  end

  def model
    current_user.setting.text_model
  end
end
