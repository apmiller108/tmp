require 'rails_helper'

RSpec.describe MarkdownToHtml do
  subject(:html) do
    Nokogiri::HTML.fragment(described_class.call(markdown:))
  end

  before do
    allow(Commonmarker).to receive(:to_html).and_call_original
  end

  let(:markdown) do
    <<~MARKDOWN
      # Hello World
      ```ruby
        puts 'hello world
      ```
    MARKDOWN
  end

  it 'converts the markdown to HTML' do
    html
    expect(Commonmarker).to have_received(:to_html).with(markdown,
                                                         options: { parse: { smart: true } },
                                                         plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } })
  end

  it 'removes anchor tags from headings' do
    heading = html.css('h1').first
    expect(heading.css('a')).to be_empty
  end
end
