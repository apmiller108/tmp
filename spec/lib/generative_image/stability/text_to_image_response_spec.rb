require 'rails_helper'

RSpec.describe GenerativeImage::Stability::TextToImageResponse do
  subject(:response) { described_class.new(client_response) }

  context 'with v2 responses' do
    let(:headers) { { 'finish-reason' => 'SUCCESS', 'seed' => '1234' } }

    let(:client_response) do
      response = Data.define :body, :headers
      response.new body: 'raw-image-bytes', headers:
    end

    describe '#image' do
      it 'returns the raw image bytes (client response body)' do
        expect(response.image).to eq(client_response.body)
      end
    end

    describe '#seed' do
      it 'returns the seed from header' do
        expect(response.seed).to eq(headers['seed'])
      end
    end

    describe '#finish_reason' do
      it 'returns the finish reason from the parsed JSON' do
        expect(response.finish_reason).to eq(headers['finish-reason'])
      end
    end

    describe '#image_present?' do
      context 'when image raw bytes is present' do
        it 'returns true' do
          expect(response.image_present?).to be true
        end
      end

      context 'when image is blank' do
        let(:client_response) do
          response = Data.define :body, :headers
          response.new body: '', headers: { 'finish-reason' => 'SUCCESS', 'seed' => '1234' }
        end

        it 'returns false' do
          expect(response.image_present?).to be false
        end
      end
    end
  end
end
