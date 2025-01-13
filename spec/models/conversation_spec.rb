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
    let!(:generate_text_requests) { create_list(:generate_text_request, 2, :completed, :with_response, conversation:) }
    let(:expected_result) { generate_text_requests.flat_map(&:to_turn) }

    it 'returns flattened turns from completed generate text requests' do
      expect(conversation.exchange).to eq(expected_result)
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
end
