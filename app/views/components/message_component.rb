# frozen_string_literal: true

class MessageComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end

  def frame_id
    dom_id(message, 'turbo_frame')
  end
end
