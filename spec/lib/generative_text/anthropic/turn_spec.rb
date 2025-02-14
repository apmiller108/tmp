require 'rails_helper'

RSpec.describe GenerativeText::Anthropic::Turn do
  describe '.for' do
    subject(:turn) { described_class.for(generate_text_request, turns:) }

    let(:conversation_turn) do
      build_stubbed :conversation_turn, turnable: generate_text_request
    end
    let(:turns) { [conversation_turn] }

    let(:generate_text_request) do
      build_stubbed(:generate_text_request, :with_response, prompt: 'Test prompt')
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

    context 'with a file' do
      let(:generate_text_request) do
        build(:generate_text_request, :with_response, prompt: 'Test prompt', file: blob, model:)
      end
      let(:model) { GenerativeText::Anthropic::MODELS.find { |m| m.capabilities.image? }.api_name }
      let(:io) { File.open Rails.root.join('spec/fixtures/files/image.png') }
      let!(:blob) { ActiveStorage::Blob.create_and_upload!(io:, filename: 'image.png') }
      let(:variant) { instance_double ActiveStorage::VariantWithRecord, image: }
      let(:image) { instance_double ActiveStorage::Blob, content_type: 'image/webp' }

      before do
        allow(blob).to(
          receive(:variant).with(
            { resize_to_limit: [1024, 768] }.merge(ActiveStorage::Blob::WEBP_VARIANT_OPTS)
          )
        ).and_return(variant)
        allow(BlobEncoder).to receive(:encode64).with(image).and_return('base64 string')
      end

      after do
        FileUtils.rm_rf(ActiveStorage::Blob.service.root)
      end

      it 'prepends an image message' do
        expect(turn[0]).to eq({
          'role' => 'user',
          'content' => [
            {
              'type' => 'image',
              'source' => {
                'type' => 'base64',
                'media_type' => 'image/webp',
                'data' => 'base64 string'
              },
              'cache_control' => { 'type' => 'ephemeral' }
            },
            { 'text' => 'Test prompt', 'type' => 'text' }
          ]
        })
      end
    end

    context 'when the previous turn is an image request' do
      pending "add specs #{__FILE__}"
    end

    context 'when response is nil' do
      let(:generate_text_request) { build(:generate_text_request, prompt: 'Test prompt') }

      it 'uses "no content" for assistant turn' do
        expect(turn[1]['content']).to eq('no content')
      end
    end
  end
end
