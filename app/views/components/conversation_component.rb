# frozen_string_literal: true

class ConversationComponent < ApplicationViewComponent
  attr_reader :conversation

  def initialize(conversation:)
    @conversation = conversation
  end
end
