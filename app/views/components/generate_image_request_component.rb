# frozen_string_literal: true

class GenerateImageRequestComponent < ApplicationViewComponent
  attr_reader :generate_image_request, :conversation_turn

  delegate :created?, :in_progress?, :failed?, :image, to: :generate_image_request

  delegate :conversation, to: :conversation_turn

  def initialize(generate_image_request, conversation_turn:)
    @generate_image_request = generate_image_request
    @conversation_turn = conversation_turn
  end

  def id
    dom_id(generate_image_request)
  end
end
