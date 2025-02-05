# frozen_string_literal: true

class ConversationTurnComponent < ApplicationViewComponent
  attr_reader :conversation_turn

  delegate :turnable_type, :turnable, to: :conversation_turn

  def initialize(conversation_turn:)
    @conversation_turn = conversation_turn
  end

  def request_component
    "#{turnable_type}Component".constantize
  end

  def id
    dom_id(conversation_turn)
  end
end
