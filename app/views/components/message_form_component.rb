# frozen_string_literal: true

class MessageFormComponent < ApplicationViewComponent
  attr_reader :message

  def initialize(message:)
    @message = message
  end
end
