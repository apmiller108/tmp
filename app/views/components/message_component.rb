class MessageComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end

  def id
    dom_id(message)
  end

  def show_linkable?
    current_page?(user_messages_path(current_user))
  end
end
