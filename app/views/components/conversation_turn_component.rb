# frozen_string_literal: true

class ConversationTurnComponent < ApplicationViewComponent
  attr_reader :generate_text_request

  delegate :prompt, :response, :pending_response?, to: :generate_text_request

  # @param [GenerateTextRequest] generate_text_request
  def initialize(generate_text_request:)
    @generate_text_request = generate_text_request
  end

  def assistant_response
    Commonmarker.to_html(
      response.content,
      options: { parse: { smart: true } },
      plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
    )
  end

  def id
    dom_id(generate_text_request) 
  end
end
