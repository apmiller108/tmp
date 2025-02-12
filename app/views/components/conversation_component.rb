# frozen_string_literal: true

class ConversationComponent < ApplicationViewComponent
  attr_reader :conversation_form, :opts

  delegate :conversation, to: :conversation_form

  def initialize(conversation_form:, **opts)
    @conversation_form = conversation_form
    @opts = opts
  end

  def id
    dom_id(conversation)
  end
end
