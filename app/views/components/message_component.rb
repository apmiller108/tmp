# frozen_string_literal: true

class MessageComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end
end
