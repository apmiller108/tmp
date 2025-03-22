require 'rails_helper'

RSpec.describe GenerateTextRequestComponent, type: :component do
  let(:generate_text_request) do
    build_stubbed :generate_text_request, :with_preset, :with_response, model: model.api_name
  end
  let(:conversation_turn) { build_stubbed :conversation_turn, turnable: generate_text_request }
  let(:model) { GenerativeText::DEFAULT_MODEL }
  let(:component) { described_class.new(conversation_turn:) }
  let(:tokens) { 1008 }

  before do
    allow(generate_text_request).to receive(:response_token_count).and_return(tokens)
  end

  describe '#id' do
    it 'returns dom_id for generate_text_request' do
      expect(component.id).to eq ActionView::RecordIdentifier.dom_id(generate_text_request)
    end
  end

  describe '#more_info_data' do
    it 'returns a compact hash of request attributes' do
      expect(component.more_info_data).to eq({
        model: model.name,
        temperature: generate_text_request.temperature,
        preset: generate_text_request.generate_text_preset.name,
        tokens:
      })
    end
  end

  describe 'rendering' do
    subject { page }

    before { render_inline(component) }

    it { is_expected.to have_css '.c-generate-text-request' }
    it { is_expected.to have_css '.segment-user', text: generate_text_request.prompt_html }
    it { is_expected.to have_css '.segment-assistant' }
  end
end
