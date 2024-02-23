require 'rails_helper'

RSpec.describe GenerativeImage::Stability::Client do
  subject(:client) { described_class.new }

  describe '#engines' do
    let(:response_body) { file_fixture('stability/engines.json').read }

    it 'returns a list of engines' do
      stub_request(:get, 'https://api.stability.ai/v1/engines/list')
        .to_return(status: 200, body: response_body)
      expect(client.engines).to eq JSON.parse(response_body)
    end
  end

  describe '#text_to_image' do
    let(:response_json) do
      { 'artifacts' => [{ 'base64' => 'base64 string', 'seed' => 123, 'finishReason' => 'SUCCESS' }] }.to_json
    end
    let(:prompt) { build_stubbed(:prompt, :with_generate_image_request) }
    let(:args) { prompt.generate_image_request.parameterize }
    let(:request_json) { args.to_json }
    let(:path) { 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image' }
    let(:request) { instance_double(GenerativeImage::Stability::TextToImageRequest, to_json: request_json, path:) }
    let(:response) { instance_double(GenerativeImage::Stability::TextToImageResponse) }

    before do
      allow(GenerativeImage::Stability::TextToImageRequest).to receive(:new).with(args).and_return(request)
      allow(GenerativeImage::Stability::TextToImageResponse).to receive(:new).with(response_json).and_return(response)
    end

    context 'with a success response' do
      before do
        stub_request(:post, path).with(body: request_json).to_return(status: 200, body: response_json)
      end

      it 'returns the TextToImageRequest object' do
        expect(client.text_to_image(**args)).to eq(response)
      end
    end

    context 'with a 4** response' do
      let(:response_body) do
        "{\"id\":\"1234\",\"message\":\"error with request\",\"name\":\"bad_request\"}\n"
      end

      before do
        stub_request(:post, path).with(body: request_json).to_return(status: 400, body: response_body)
      end

      it 're-raises a client error' do
        expect do
          client.text_to_image(**args)
        end.to raise_error(GenerativeImage::Stability::ClientError, "400: #{response_body}")
      end
    end
  end
end
