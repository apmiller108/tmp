# frozen_string_literal: true

class ConversationTurnComponent < ApplicationViewComponent
  attr_reader :generate_text_request

  delegate :prompt, :response, :created?, :in_progress?, :failed?, :completed?,
           :model, :temperature, :generate_text_preset, :response_token_count,
           to: :generate_text_request

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

  def dataset
    {
      model: model.name,
      temperature:,
      preset: generate_text_preset&.name,
      token_count: response_token_count
    }.compact
  end
end
