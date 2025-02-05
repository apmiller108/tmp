# frozen_string_literal: true

class GenerateImageRequestComponent < ApplicationViewComponent
  attr_reader :generate_image_request

  delegate :created?, :in_progress?, :failed?, :image, to: :generate_image_request

  def initialize(generate_image_request)
    @generate_image_request = generate_image_request
  end

  def id
    dom_id(generate_image_request)
  end
end
