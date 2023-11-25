# frozen_string_literal: true

class MessageFormComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end

  def id
    dom_id(message)
  end

  def cancel_path
    message.persisted? ? user_message_path(current_user, message) : user_messages_path(current_user)
  end
end
