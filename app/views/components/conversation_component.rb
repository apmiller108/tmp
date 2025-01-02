# frozen_string_literal: true

class ConversationComponent < ApplicationViewComponent
  attr_reader :conversation, :generate_text_request

  def initialize(conversation:)
    @conversation = conversation
    @generate_text_request = current_user.generate_text_requests.new(conversation:, model:)
  end

  def model
    current_user.setting.text_model
  end

  def deletable?
    conversation.memo.nil?
  end
end
