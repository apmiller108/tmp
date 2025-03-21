require 'rails_helper'

RSpec.describe GenerateImageRequest, type: :model do
  describe '.generate_name' do
    it 'generates a unique name with timestamp and random number' do
      freeze_time do
        time = Time.new.to_i
        expect(described_class.generate_name).to match(/genimage_#{time}_\d+/)
      end
    end
  end

  describe 'custom accessors' do
    let(:request) { build(:generate_image_request, options:) }
    let(:options) { { 'quality' => GenerativeImage::HIGH_QUALITY } }

    describe '#quality' do
      it 'returns the quality' do
        expect(request.quality).to eq(GenerativeImage::HIGH_QUALITY)
      end

      context 'when the quality is not present' do
        let(:options) { {} }

        it 'returns the default' do
          expect(request.quality).to eq(GenerativeImage::DEFAULT_QUALITY_LEVEL)
        end
      end
    end
  end

  describe 'request type predicates' do
    let(:request) { build(:generate_image_request) }

    context 'when request_type is text_to_image' do
      before { request.options = { 'request_type' => 'text_to_image' } }

      it { expect(request.text_to_image?).to be true }
      it { expect(request.image_to_image?).to be false }
      it { expect(request.upscale?).to be false }
    end

    context 'when request_type is image_to_image' do
      before { request.options = { 'request_type' => 'image_to_image' } }

      it { expect(request.text_to_image?).to be false }
      it { expect(request.image_to_image?).to be true }
      it { expect(request.upscale?).to be false }
    end

    context 'when request_type is upscale' do
      before { request.options = { 'request_type' => 'upscale' } }

      it { expect(request.text_to_image?).to be false }
      it { expect(request.image_to_image?).to be false }
      it { expect(request.upscale?).to be true }
    end
  end

  describe '#prompt and #negative_prompt' do
    let(:request) { build(:generate_image_request, prompts:) }
    let(:positive_prompt) { build(:prompt, weight: 1, text: 'beautiful landscape') }
    let(:negative_prompt) { build(:prompt, weight: -1, text: 'blurry, ugly') }
    let(:prompts) { [positive_prompt, negative_prompt] }

    it 'returns the positive prompt text' do
      expect(request.prompt).to eq('beautiful landscape')
    end

    it 'returns the negative prompt text' do
      expect(request.negative_prompt).to eq('blurry, ugly')
    end

    context 'when prompts are missing' do
      let(:prompts) { [] }

      it 'returns nil for prompt' do
        expect(request.prompt).to be_nil
      end

      it 'returns nil for negative_prompt' do
        expect(request.negative_prompt).to be_nil
      end
    end
  end

  describe '#parameterize' do
    let(:prompt1) { build_stubbed :prompt }
    let(:prompt1_params) { { text: 'prompt1', weight: 1 } }
    let(:prompt2) { build_stubbed :prompt }
    let(:prompt2_params) { { text: 'prompt2', weight: -1 } }

    let(:request) do
      described_class.new(
        options: {
          'style' => GenerativeImage::Stability::STYLE_PRESETS.first,
          'aspect_ratio' => GenerativeImage::Stability::ASPECT_RATIOS.first,
          'request_type' => 'text_to_image',
          'strength' => 0.75,
          'quality' => GenerativeImage::HIGH_QUALITY
        },
        prompts: [prompt1, prompt2]
      )
    end

    before do
      allow(prompt1).to receive(:parameterize).and_return(prompt1_params)
      allow(prompt2).to receive(:parameterize).and_return(prompt2_params)
    end

    it 'returns a hash with all option fields and prompts' do
      expected_hash = {
        style: request.style,
        aspect_ratio: request.aspect_ratio,
        request_type: 'text_to_image',
        strength: 0.75,
        quality: GenerativeImage::HIGH_QUALITY,
        prompts: [prompt1_params, prompt2_params]
      }

      expect(request.parameterize).to eq(expected_hash)
    end
  end

  describe '#base_image' do
    context 'when not an image modification request' do
      let(:request) do
        build(:generate_image_request, options: { 'request_type' => 'text_to_image' })
      end

      it 'returns nil' do
        expect(request.base_image).to be_nil
      end
    end

    context 'when image_to_image with generate_text_request' do
      let(:text_request) { create(:generate_text_request) }
      let(:request) do
        build(:generate_image_request,
              options: { 'request_type' => 'image_to_image' },
              generate_text_request: text_request)
      end

      before do
        file = fixture_file_upload('image.png', 'image/png')
        text_request.file.attach(file)
      end

      it 'returns the processed image from generate_text_request' do
        expect(request.base_image.filename.to_s).to eq 'image.webp'
      end
    end

    context 'when upscale with baseimage' do
      let(:text_request) { create(:generate_text_request) }
      let(:request) do
        build(:generate_image_request,
              options: { 'request_type' => 'upscale' },
              generate_text_request: text_request)
      end

      before do
        file = fixture_file_upload('image.png', 'image/png')
        text_request.file.attach(file)
      end

      it 'returns the processed baseimage' do
        expect(request.base_image.filename.to_s).to eq 'image.webp'
      end
    end
  end
end
