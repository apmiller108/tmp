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

  # Heading anchor tags are removed as they will interfere with the Scrollspy
  def assistant_response
    formatted_assistant_response
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

  private

  def assistant_response_html
    Commonmarker.to_html(
      response.content,
      options: {
        parse: { smart: true }
      },
      plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
    )
  end

  def formatted_assistant_response
    doc = Nokogiri::HTML.fragment(assistant_response_html)

    # Remove anchor tags
    doc.css('a[aria-hidden="true"].anchor').each(&:remove)

    # Wrap pre tags in a ClipboardComponent
    doc.css('pre').each do |pre_tag|
      pre_tag.replace(
        Nokogiri::HTML.fragment(copyable_pre(pre_tag))
      )
    end

    doc.to_html
  end

  # rubocop:disable Rails/OutputSafety
  def copyable_pre(pre_tag)
    original_content = pre_tag.inner_html
    attributes = pre_tag.attributes.transform_values(&:value)

    # Create a new fragment with the rendered component
    render ClipboardComponent.new(css_class: 'prompt', y: :top, x: :end) do |c|
      c.with_copyable do
        content_tag(:pre, original_content.html_safe,
                    data: { 'clipboard-target' => 'source' },
                    **attributes)
      end
    end
  end
  # rubocop:enable Rails/OutputSafety
end
