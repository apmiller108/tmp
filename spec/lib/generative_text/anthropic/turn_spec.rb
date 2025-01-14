require 'rails_helper'

RSpec.describe GenerativeText::Anthropic::Turn do
  describe '.for' do
    subject(:turn) { described_class.for(generate_text_request) }

    let(:generate_text_request) do
      build(:generate_text_request, :with_response, prompt: 'Test prompt')
    end

    it 'returns an array with two elements' do
      expect(turn.size).to eq(2)
    end

    it 'creates a user turn with correct structure' do
      expect(turn[0]).to eq({
        'role' => 'user',
        'content' => [
          { 'text' => 'Test prompt', 'type' => 'text' }
        ]
      })
    end

    it 'creates an assistant turn with correct structure' do
      expect(turn[1]).to eq({
        'role' => 'assistant',
        'content' => 'test response'
      })
    end

    context 'when response is nil' do
      let(:generate_text_request) { build(:generate_text_request, prompt: 'Test prompt') }

      it 'uses "no content" for assistant turn' do
        expect(turn[1]['content']).to eq('no content')
      end
    end
  end
end
