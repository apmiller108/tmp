# frozen_string_literal: true

class GenerateTextRequestComponent < ApplicationViewComponent
  attr_reader :generate_text_request, :conversation_turn

  delegate :prompt_html, :response, :created?, :in_progress?, :failed?, :completed?,
           :model, :temperature, :generate_text_preset, :response_token_count,
           :file, :assistant_response_html, to: :generate_text_request

  delegate :conversation, to: :conversation_turn

  # @param [ConversationTurn] generate_text_request
  def initialize(conversation_turn:, readonly: false)
    @conversation_turn = conversation_turn
    @generate_text_request = conversation_turn.turnable
    @readonly = readonly
  end

  # Heading anchor tags are removed as they will interfere with the Scrollspy
  def assistant_response
    response.content
  end

  def id
    dom_id(generate_text_request)
  end

  def user_message_id
    dom_id(generate_text_request, 'user_message')
  end

  def assistant_response_id
    dom_id(generate_text_request, 'assistant_response')
  end

  def more_info_data
    {
      model: model.name,
      temperature:,
      preset: generate_text_preset&.name,
      tokens: response_token_count
    }.compact
  end

  # rubocop:disable Rails/OutputSafety
  def more_info_template
    tag.div(class: 'details-fields p-0') do
      more_info_data.map do |k, v|
        tag.div(class: 'd-flex align-items-center justify-content-between') do
          tag.span("#{k.to_s.titleize}:", class: 'label me1') + tag.pre(v, class: 'value mb-0 p-1')
        end
      end.join("\n").html_safe
    end
  end
  # rubocop:enable Rails/OutputSafety

  def image?
    file.attached? && file.image?
  end

  def image_variant_options
    {
      resize_to_limit: [100, 100],
      **ActiveStorage::Blob::WEBP_VARIANT_OPTS
    }
  end

  def bot_icon
    case model.vendor
    when :google
      'bi-google'
    else
      'bi-robot'
    end
  end

  def readonly?
    @readonly
  end
end
