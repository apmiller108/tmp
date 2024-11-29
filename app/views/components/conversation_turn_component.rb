# frozen_string_literal: true

class ConversationTurnComponent < ApplicationViewComponent
  attr_reader :turn

  delegate :assistant?, :content, to: :turn

  def initialize(turn)
    @turn = turn
  end

  def icon_class
    if assistant?
      'bi-robot'
    else
      'bi-person-fill'
    end
  end
end
