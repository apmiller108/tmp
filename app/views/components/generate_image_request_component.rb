# frozen_string_literal: true

class GenerateImageRequestComponent < ApplicationViewComponent
  attr_reader :generate_image_request, :conversation_turn

  delegate :created?, :in_progress?, :failed?, :image, to: :generate_image_request

  delegate :conversation, to: :conversation_turn

  def initialize(conversation_turn:)
    @conversation_turn = conversation_turn
    @generate_image_request = conversation_turn.turnable
  end

  def id
    dom_id(generate_image_request)
  end
end
