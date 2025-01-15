require 'rails_helper'

RSpec.describe ConversationTurnComponent, type: :component do
  let(:generate_text_request) do
    build_stubbed :generate_text_request, :with_preset, :with_response, model: model.api_name
  end
  let(:model) { GenerativeText::Anthropic::DEFAULT_MODEL }
  let(:component) { described_class.new(generate_text_request:) }
  let(:token_count) { 1008 }

  before do
    allow(generate_text_request).to receive(:response_token_count).and_return(token_count)
  end

  describe '#assistant_response' do
    it 'converts markdown to HTML' do
      expect(Commonmarker).to receive(:to_html).with(
        generate_text_request.response.content,
        options: { parse: { smart: true } },
        plugins: { syntax_highlighter: { theme: 'Solarized (dark)' } }
      )
      component.assistant_response
    end
  end

  describe '#id' do
    it 'returns dom_id for generate_text_request' do
      expect(component.id).to eq ActionView::RecordIdentifier.dom_id(generate_text_request)
    end
  end

  describe '#dataset' do
    it 'returns a compact hash of request attributes' do
      expect(component.dataset).to eq({
        model: model.name,
        temperature: generate_text_request.temperature,
        preset: generate_text_request.generate_text_preset.name,
        token_count:
      })
    end
  end

  describe 'rendering' do
    subject { page }

    before { render_inline(component) }

    it { is_expected.to have_css '.c-conversation-turn' }
    it { is_expected.to have_css '.segment-user', text: generate_text_request.prompt }
    it { is_expected.to have_css '.segment-assistant' }
  end
end
