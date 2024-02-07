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
    let(:png) { 'png' }
    let(:prompt) { 'hubble space telescope galaxy' }
    let(:request_json) { { prompt:, opt1: 'opt1', opt2: 'opt2' }.to_json }
    let(:path) { 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image' }
    let(:request) { instance_double(GenerativeImage::Stability::TextToImageRequest, to_json: request_json, path:) }

    before do
      allow(GenerativeImage::Stability::TextToImageRequest).to receive(:new).and_return(request)
    end

    context 'with a success response' do
      before do
        stub_request(:post, path).with(body: request_json).to_return(status: 200, body: png)
      end

      it 'returns a PNG file binary' do
        expect(client.text_to_image(prompt:)).to eq(png)
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
          client.text_to_image(prompt: '')
        end.to raise_error(GenerativeImage::Stability::ClientError, "400: #{response_body}")
      end
    end
  end
end
