require 'rails_helper'

RSpec.describe GenerativeImage::Stability::TextToImageResponse do
  subject(:response) { described_class.new(data.to_json) }

  let(:data) do
    { 'artifacts' => [{ 'base64' => 'base64 string', 'seed' => 123, 'finishReason' => 'SUCCESS' }] }
  end

  describe '#base64' do
    it 'returns the base64 string from the parsed JSON' do
      puts data
      expect(response.base64).to eq(data['artifacts'][0]['base64'])
    end
  end

  describe '#seed' do
    it 'returns the seed from the parsed JSON' do
      expect(response.seed).to eq(data['artifacts'][0]['seed'])
    end
  end

  describe '#finish_reason' do
    it 'returns the finish reason from the parsed JSON' do
      expect(response.finish_reason).to eq(data['artifacts'][0]['finishReason'])
    end
  end

  describe '#image_present?' do
    context 'when base64 is present' do
      it 'returns true' do
        expect(response.image_present?).to be true
      end
    end

    context 'when base64 is blank' do
      let(:data) do
        { 'artifacts' => [{ 'base64' => '', 'seed' => 123, 'finishReason' => 'SUCCESS' }] }
      end

      it 'returns false' do
        expect(response.image_present?).to be false
      end
    end
  end
end
