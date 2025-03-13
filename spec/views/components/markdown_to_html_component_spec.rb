# froze_string_literal: true
#
require 'rails_helper'

RSpec.describe MarkdownToHtmlComponent, type: :component do
  subject { page }

  let(:component) { described_class.new(markdown:) }

  let(:markdown) do
    <<~MARKDOWN
      # Hello World
      ```ruby
        puts 'hello world
      ```
    MARKDOWN
  end

  before { render_inline(component) }

  it 'removes anchor tags from headings' do
    expect(page).to have_css 'h1', text: 'Hello World'
    expect(page).not_to have_css 'h1#hello-world'
  end

  it 'wraps the pre tags in a ClipboardComponent' do
    expect(page).to have_css '.c-clipboard > pre[data-clipboard-target="source"]'
  end
end
