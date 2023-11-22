class MessageComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end

  def id
    dom_id(message)
  end
end
