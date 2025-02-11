# frozen_string_literal: true

class ConversationComponent < ApplicationViewComponent
  attr_reader :conversation_form

  delegate :conversation, to: :conversation_form

  def initialize(conversation_form:)
    @conversation_form = conversation_form
  end

  def id
    dom_id(conversation)
  end
end
