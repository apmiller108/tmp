# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  attr_reader :generate_text_request

  def initialize(generate_text_request:)
    @generate_text_request = generate_text_request
  end
end
