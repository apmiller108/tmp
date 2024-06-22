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
    let(:prompt) { build_stubbed(:prompt, :with_generate_image_request) }
    let(:args) { prompt.generate_image_request.parameterize }
    let(:request_json) { args.to_json }
    let(:path) { 'https://api.stability.ai/v2beta/stable-image/generate/core' }
    let(:request) { instance_double(GenerativeImage::Stability::TextToImageRequest, to_json: request_json, path:) }
    let(:headers) do
      {
        'Authorization': "Bearer #{Rails.application.credentials.fetch(:stability_key)}",
        'Accept': 'image/*'
      }
    end

    before do
      allow(GenerativeImage::Stability::TextToImageRequest).to receive(:new).with(args).and_return(request)
    end

    context 'with a success response' do
      before do
        stub_request(:post, path).with(headers:).to_return(status: 200, body: 'raw image bytes')
      end

      it 'returns the TextToImageRequest object' do
        expect(client.text_to_image(**args)).to  be_a GenerativeImage::Stability::TextToImageResponse
      end
    end

    context 'with a 4** response' do
      let(:response_body) do
        "{\"id\":\"1234\",\"message\":\"error with request\",\"name\":\"bad_request\"}\n"
      end

      before do
        stub_request(:post, path).with(headers:).to_return(status: 400, body: response_body)
      end

      it 're-raises a client error' do
        expect do
          client.text_to_image(**args)
        end.to raise_error(GenerativeImage::Stability::ClientError, "400: #{response_body}")
      end
    end
  end
end
