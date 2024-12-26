# frozen_string_literal: true

class ConversationTurnComponent < ApplicationViewComponent
  attr_reader :turn, :pending

  delegate :assistant?, to: :turn

  alias pending? pending

  PENDING_RESPONSE_DOM_ID = 'pending-response'

  # @param [Conversation::Turn] turn
  def initialize(turn, pending: false)
    @turn = turn
    @pending = pending
  end

  def content
    if assistant?
      Commonmarker.to_html(
        turn.content,
        options: { parse: { smart: true } },
        plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
      )
    else
      turn.content
    end
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
