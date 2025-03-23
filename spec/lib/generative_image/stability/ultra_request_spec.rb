require 'rails_helper'

RSpec.describe GenerativeImage::Stability::UltraRequest do
  subject(:request) { described_class.new(generate_image_request) }

  let(:generate_image_request) { build_stubbed :generate_image_request, options:, prompts: }
  let(:prompt) { build :prompt, text: 'prompt text', weight: 1 }
  let(:negative_prompt) { build :prompt, text: 'negative prompt text', weight: -1 }
  let(:prompts) { [prompt, negative_prompt] }
  let(:request_type) { 'text_to_image' }
  let(:options) do
    {
      style: GenerativeImage::Stability::STYLE_PRESETS.sample,
      aspect_ratio: GenerativeImage::Stability::ASPECT_RATIOS.sample,
      strength: 0.7,
      request_type:
    }
  end

  it { is_expected.to be_a GenerativeImage::Stability::BaseRequest }

  describe '#path' do
    it 'returns the ULTRA_GENERATION_ENDPOINT' do
      expect(request.path).to eq(GenerativeImage::Stability::ULTRA_GENERATION_ENDPOINT)
    end
  end

  describe '#as_json' do
    let(:base_image) { nil }

    before do
      allow(generate_image_request).to receive(:base_image).and_return base_image
    end

    it 'returns the expected JSON structure' do
      expect(request.as_json).to eq(prompt: 'prompt text',
                                    negative_prompt: 'negative prompt text',
                                    style_preset: options.fetch(:style),
                                    aspect_ratio: options.fetch(:aspect_ratio),
                                    output_format: 'png',
                                    seed: 0)
    end

    context 'when there is a base_image' do
      let(:base_image) do
        double('ActiveStorage::Attached::One',
               image?: true, filename: 'image.png', download: 'downloaded contents', content_type: 'image/png')
      end
      let(:upload_io) { instance_double Multipart::Post::UploadIO }
      let(:request_type) { 'image_to_image' }

      before do
        allow(Faraday::UploadIO).to receive(:new).and_return(upload_io)
      end

      it 'returns the expected JSON structure including the image and strength' do
        expect(request.as_json).to eq(prompt: 'prompt text',
                                      negative_prompt: 'negative prompt text',
                                      style_preset: options.fetch(:style),
                                      aspect_ratio: options.fetch(:aspect_ratio),
                                      strength: options.fetch(:strength),
                                      image: upload_io,
                                      output_format: 'png',
                                      seed: 0)
      end
    end
  end
end
