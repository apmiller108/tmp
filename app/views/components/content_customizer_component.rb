# frozen_string_literal: true

class ContentCustomizerComponent < ApplicationViewComponent
  attr_reader :markup

  # @param markup [String] markdown or html formatted string
  # @option opts [Boolean] :simple (true) no rendering customizations
  # @option opts [Boolean] :markdown (false) indicates that the markup is markdown and will be converted to HTML
  def initialize(markup:, **opts)
    @markup = markup
    @opts = opts
  end

  def extended_html
    return html if simple?

    doc = Nokogiri::HTML.fragment(html)
    doc.css('pre').each do |pre_tag|
      pre_tag.replace(
        Nokogiri::HTML.fragment(customized_pre(pre_tag))
      )
    end

    doc.to_html
  end

  private

  def html
    if markdown?
      MarkdownToHtml.call(markdown: markup)
    else
      markup
    end
  end

  def simple?
    @opts.fetch(:simple, false)
  end

  def markdown?
    @opts.fetch(:markdown, false)
  end

  # rubocop:disable Rails/OutputSafety, Metrics/MethodLength
  def customized_pre(pre_tag)
    original_content = pre_tag.inner_html
    attributes = pre_tag.attributes.transform_values(&:value)

    # Special handling for mermaid diagrams
    # Extract only the text content, stripping all HTML tags produced by
    # the conversation of markdown to HTML
    if attributes['lang'] == 'mermaid'
      original_content = pre_tag.text.strip
      attributes['style'] = nil
      attributes['data-copyable'] = original_content
    end

    # Wrap pre tags in a ClipboardComponent
    render ClipboardComponent.new(css_class: 'pre-content', y: :top, x: :end) do |c|
      c.with_copyable do
        content_tag(:pre, original_content.html_safe,
                    data: { 'clipboard-target' => 'source' },
                    **attributes)
      end
    end
  end
  # rubocop:enable Rails/OutputSafety, Metrics/MethodLength
end
