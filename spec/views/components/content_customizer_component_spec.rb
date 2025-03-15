# froze_string_literal: true
#
require 'rails_helper'

RSpec.describe ContentCustomizerComponent, type: :component do
  subject { page }

  let(:component) { described_class.new(markup:) }

  let(:markup) do
    <<~MARKDOWN
      <h1>Hello World</h1>
        <pre style="background: #fff;">
          <span>puts 'hello world</span>
        </pre>
    MARKDOWN
  end

  context 'with html' do
    before { render_inline(component) }

    it 'wraps the pre tags in a ClipboardComponent' do
      expect(page).to have_css '.c-clipboard > pre[data-clipboard-target="source"]'
    end
  end

  context 'when :markdown option is true' do
    let(:component) { described_class.new(markup:, markdown: true) }

    before do
      allow(MarkdownToHtml).to receive(:call).and_return markup
      render_inline(component)
    end

    it 'converts the markup to HTML' do
      expect(MarkdownToHtml).to have_received(:call)
    end

    it 'wraps the pre tags in a ClipboardComponent' do
      expect(page).to have_css '.c-clipboard > pre[data-clipboard-target="source"]'
    end
  end

  context 'when :simple option is true' do
    let(:component) { described_class.new(markup:, simple: true) }

    before { render_inline(component) }

    it 'does not wraps the pre tags in a ClipboardComponent' do
      expect(page).not_to have_css '.c-clipboard > pre[data-clipboard-target="source"]'
    end
  end
end
