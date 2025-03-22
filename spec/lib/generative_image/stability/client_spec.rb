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

  describe '#perform_request' do
    let(:generate_image_request) { build_stubbed(:generate_image_request) }
    let(:request) do
      instance_double(GenerativeImage::Stability::BaseRequest, path: endpoint, as_json: request_json, close: nil)
    end
    let(:request_json) { { prompt: 'test prompt' } }
    let(:endpoint) { 'v2beta/stable-image/generate/core' }
    let(:full_endpoint) { "https://api.stability.ai/#{endpoint}" }

    before do
      allow(GenerativeImage::Stability::RequestFactory).to receive(:create).and_return(request)
    end

    context 'with a text-to-image request' do
      before do
        allow(generate_image_request).to receive(:image_to_image?).and_return(false)
        allow(generate_image_request).to receive(:high_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:standard_quality_text_to_image?).and_return(true)
        allow(generate_image_request).to receive(:upscale?).and_return(false)

        stub_request(:post, full_endpoint)
          .to_return(status: 200, body: 'raw image bytes')
      end

      it 'returns an ImageResponse object' do
        response = client.perform_request(generate_image_request)
        expect(response).to be_a GenerativeImage::Stability::ImageResponse
      end
    end

    context 'with a high quality text-to-image request' do
      let(:endpoint) { 'v2beta/stable-image/generate/ultra' }
      let(:full_endpoint) { "https://api.stability.ai/#{endpoint}" }

      before do
        allow(generate_image_request).to receive(:image_to_image?).and_return(false)
        allow(generate_image_request).to receive(:high_quality_text_to_image?).and_return(true)
        allow(generate_image_request).to receive(:standard_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:upscale?).and_return(false)

        stub_request(:post, full_endpoint)
          .to_return(status: 200, body: 'raw image bytes')
      end

      it 'returns an ImageResponse object' do
        response = client.perform_request(generate_image_request)
        expect(response).to be_a GenerativeImage::Stability::ImageResponse
      end
    end

    context 'with an image-to-image request' do
      let(:endpoint) { 'v2beta/stable-image/generate/ultra' }
      let(:full_endpoint) { "https://api.stability.ai/#{endpoint}" }

      before do
        allow(generate_image_request).to receive(:image_to_image?).and_return(true)
        allow(generate_image_request).to receive(:high_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:standard_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:upscale?).and_return(false)

        stub_request(:post, full_endpoint)
          .to_return(status: 200, body: 'raw image bytes')
      end

      it 'returns an ImageResponse object' do
        response = client.perform_request(generate_image_request)
        expect(response).to be_a GenerativeImage::Stability::ImageResponse
      end
    end

    context 'with an upscale request' do
      let(:endpoint) { 'v2beta/stable-image/upscale/fast' }
      let(:full_endpoint) { "https://api.stability.ai/#{endpoint}" }

      before do
        allow(generate_image_request).to receive(:image_to_image?).and_return(false)
        allow(generate_image_request).to receive(:high_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:standard_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:upscale?).and_return(true)

        stub_request(:post, full_endpoint)
          .to_return(status: 200, body: 'raw image bytes')
      end

      it 'returns an ImageResponse object' do
        response = client.perform_request(generate_image_request)
        expect(response).to be_a GenerativeImage::Stability::ImageResponse
      end
    end

    context 'with a 403 response' do
      let(:response_body) { '{"id":"1234","message":"forbidden","name":"forbidden"}' }

      before do
        allow(generate_image_request).to receive(:image_to_image?).and_return(false)
        allow(generate_image_request).to receive(:high_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:standard_quality_text_to_image?).and_return(true)
        allow(generate_image_request).to receive(:upscale?).and_return(false)

        stub_request(:post, full_endpoint)
          .to_return(status: 403, body: response_body)
      end

      it 'raises a ContentError' do
        expect do
          client.perform_request(generate_image_request)
        end.to raise_error(GenerativeImage::Stability::ContentError)
      end
    end

    context 'with a non-403 error response' do
      let(:response_body) { '{"id":"1234","message":"error with request","name":"bad_request"}' }

      before do
        allow(generate_image_request).to receive(:image_to_image?).and_return(false)
        allow(generate_image_request).to receive(:high_quality_text_to_image?).and_return(false)
        allow(generate_image_request).to receive(:standard_quality_text_to_image?).and_return(true)
        allow(generate_image_request).to receive(:upscale?).and_return(false)

        stub_request(:post, full_endpoint)
          .to_return(status: 400, body: response_body)
      end

      it 'raises a ClientError' do
        expect do
          client.perform_request(generate_image_request)
        end.to raise_error(GenerativeImage::Stability::ClientError)
      end
    end
  end
end
