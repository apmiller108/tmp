# frozen_string_literal: true

class GenerateTextRequestComponent < ApplicationViewComponent
  attr_reader :generate_text_request, :conversation_turn

  delegate :prompt, :response, :created?, :in_progress?, :failed?, :completed?,
           :model, :temperature, :generate_text_preset, :response_token_count,
           :file, to: :generate_text_request

  delegate :conversation, to: :conversation_turn

  # @param [ConversationTurn] generate_text_request
  def initialize(conversation_turn:)
    @conversation_turn = conversation_turn
    @generate_text_request = conversation_turn.turnable
  end

  def assistant_response
    Commonmarker.to_html(
      response.content,
      options: {
        parse: { smart: true }
      },
      plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
    )
  end

  def id
    dom_id(generate_text_request)
  end

  def user_message_id
    "#{id}_user"
  end

  def assistant_response_id
    "#{id}_assistant"
  end

  def dataset
    {
      model: model.name,
      temperature:,
      preset: generate_text_preset&.name,
      token_count: response_token_count
    }.compact
  end

  def image?
    file.attached? && file.image?
  end

  def image_variant_options
    {
      resize_to_limit: [100, 100],
      **ActiveStorage::Blob::WEBP_VARIANT_OPTS
    }
  end
end
