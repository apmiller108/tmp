# frozen_string_literal: true

class PromptFormComponent < ApplicationViewComponent
  attr_reader :generate_text_request

  renders_one :delete_button

  def initialize(generate_text_request:, **opts)
    @generate_text_request = generate_text_request
    @opts = opts
  end

  def show_options?
    @opts[:show_options]
  end
end
