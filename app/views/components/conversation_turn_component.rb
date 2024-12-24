# frozen_string_literal: true

class ConversationTurnComponent < ApplicationViewComponent
  attr_reader :turn, :pending

  delegate :assistant?, :content, to: :turn

  alias pending? pending

  PENDING_RESPONSE_DOM_ID = 'pending-response'

  # @param [Conversation::Turn] turn
  def initialize(turn, pending: false)
    @turn = turn
    @pending = pending
  end

  def id
    PENDING_RESPONSE_DOM_ID if pending?
  end

  def icon_class
    if assistant?
      'bi-robot'
    else
      'bi-person-fill'
    end
  end
end
