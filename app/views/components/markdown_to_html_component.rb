# frozen_string_literal: true

class MarkdownToHtmlComponent < ApplicationViewComponent
  attr_reader :markdown

  # @param markdown [String] markdown formatted string
  def initialize(markdown:)
    @markdown = markdown
  end

  def extended_html
    doc = Nokogiri::HTML.fragment(html)

    # Remove anchor tags. These can be malformed and cause issues with the
    # scrollspy intialization.
    doc.css('a.anchor').each(&:remove)

    # Wrap pre tags in a ClipboardComponent
    doc.css('pre').each do |pre_tag|
      pre_tag.replace(
        Nokogiri::HTML.fragment(customized_pre(pre_tag))
      )
    end

    doc.to_html
  end

  private

  def html
    sanitize(
      Commonmarker.to_html(
        markdown,
        options: {
          parse: { smart: true }
        },
        plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
      )
    )
  end

  # rubocop:disable Rails/OutputSafety, Metrics/MethodLength
  def customized_pre(pre_tag)
    original_content = pre_tag.inner_html
    attributes = pre_tag.attributes.transform_values(&:value)

    # Special handling for mermaid diagrams
    # Extract only the text content, stripping all HTML tags produced by
    # Commonmarker
    if attributes['lang'] == 'mermaid'
      original_content = pre_tag.text.strip
      attributes['style'] = nil
      attributes['data-mermaid'] = original_content
    end

    # Create a new fragment with the rendered component
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
