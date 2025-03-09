# frozen_string_literal: true

class MarkdownToHtmlComponent < ApplicationViewComponent
  attr_reader :markdown

  def initialize(markdown:)
    @markdown = markdown
  end

  def extended_html
    doc = Nokogiri::HTML.fragment(html)

    # Remove anchor tags. These can be malformed and cause issues with JS
    # frameworks.
    doc.css('a[aria-hidden="true"].anchor').each(&:remove)

    # Wrap pre tags in a ClipboardComponent
    doc.css('pre').each do |pre_tag|
      pre_tag.replace(
        Nokogiri::HTML.fragment(copyable_pre(pre_tag))
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
end
