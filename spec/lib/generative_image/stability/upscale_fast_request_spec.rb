require 'rails_helper'

RSpec.describe GenerativeImage::Stability::UpscaleFastRequest do
  subject(:request) { described_class.new(generate_image_request) }

  let(:generate_image_request) { build_stubbed :generate_image_request, options: }
  let(:request_type) { 'upscale' }
  let(:options) do
    {
      request_type:
    }
  end

  it { is_expected.to be_a GenerativeImage::Stability::BaseRequest }

  describe '#path' do
    it 'returns the UPSCALE_FAST_ENDPOINT' do
      expect(request.path).to eq(GenerativeImage::Stability::UPSCALE_FAST_ENDPOINT)
    end
  end

  describe '#as_json' do
    let(:base_image) do
      double('ActiveStorage::Attached::One',
             image?: true, filename: 'image.png', download: 'downloaded contents', content_type: 'image/png')
    end
    let(:upload_io) { instance_double Multipart::Post::UploadIO }

    before do
      allow(generate_image_request).to receive(:base_image).and_return base_image
      allow(Faraday::UploadIO).to receive(:new).and_return(upload_io)
    end

    it 'returns the expected JSON structure' do
      expect(request.as_json).to eq(image: upload_io,
                                    output_format: 'png')
    end
  end
end
