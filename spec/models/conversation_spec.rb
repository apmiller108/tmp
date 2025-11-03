require 'rails_helper'

RSpec.describe Conversation, type: :model do
  subject(:conversation) { build(:conversation) }

  describe '.title_from_prompt' do
    it 'truncates prompt to 40 characters with elipses' do
      prompt = 'This is a very long prompt that should be truncated'
      expect(described_class.title_from_prompt(prompt)).to eq('This is a very long prompt that...')
    end
  end

  describe '#exchange' do
    let(:turns) { conversation.turns }

    before do
      create_list(:generate_text_request, 2, :completed, :with_response, conversation:)
    end

    let(:expected_result) { turns.flat_map { _1.turnable.to_turn(turns:) } }

    it 'returns flattened turns from completed generate text requests' do
      expect(conversation.exchange).to eq(expected_result)
    end
  end

  describe '#documents' do
    context 'when there are no contexts' do
      it 'returns an empty array' do
        expect(conversation.documents).to eq([])
      end
    end

    context 'when there are contexts' do
      let(:context1) { create(:conversation_context) }
      let(:context2) { create(:conversation_context) }

      before do
        conversation.contexts << context1
        conversation.contexts << context2
      end

      it 'returns content blocks from associated contexts' do
        expected_documents = [
          context1.to_content_block,
          context2.to_content_block
        ]
        expect(conversation.documents).to eq(expected_documents)
      end
    end
  end

  describe '#token_count' do
    let(:generate_text_requests) { create_list(:generate_text_request, 3, conversation:) }

    let(:expected_result) do
      generate_text_requests.sum(&:response_token_count)
    end

    it 'sums the token count from generate text requests' do
      expect(conversation.token_count).to eq(expected_result)
    end
  end

  describe '#blobify' do
    subject(:conversation) { build_stubbed(:conversation, title: 'Test Conversation') }

    let(:generate_text_requests) { GenerateTextRequest.none }

    before do
      allow(conversation).to receive(:generate_text_requests).and_return(generate_text_requests)
      allow(generate_text_requests).to receive(:completed).and_return(completed_requests)
    end

    context 'when there are no completed text requests' do
      let(:completed_requests) { [] }

      it 'returns only the title' do
        expect(conversation.blobify).to eq('Test Conversation')
      end
    end

    context 'when there are completed text requests' do
      let(:text_request1) { build_stubbed(:generate_text_request) }
      let(:text_request2) { build_stubbed(:generate_text_request) }
      let(:completed_requests) { [text_request1, text_request2] }

      before do
        allow(text_request1).to receive(:blobify).and_return('First request blob')
        allow(text_request2).to receive(:blobify).and_return('Second request blob')
      end

      it 'combines the title with the blobified text requests' do
        expect(conversation.blobify).to eq('Test Conversation First request blob Second request blob')
      end
    end
  end
end
