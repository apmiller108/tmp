class MarkdownToHtml
  include ActionView::Helpers::SanitizeHelper

  # Converts markdown to HTML
  # @param markdown [String] markdown formatted string
  # @return [String] HTML string
  def self.call(markdown:)
    new(markdown).convert
  end

  def initialize(markdown)
    @markdown = markdown
  end

  def convert
    doc = Nokogiri::HTML.fragment(html)
    # Remove anchor tags. These can be malformed and cause issues with the
    # scrollspy intialization.
    doc.css('a.anchor').each(&:remove)
    doc.to_html
  end

  private

  def html
    sanitize(
      Commonmarker.to_html(
        @markdown,
        options: {
          parse: { smart: true }
        },
        plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
      )
    )
  end
end
