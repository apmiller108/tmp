require 'rails_helper'

RSpec.describe GenerativeImage::Stability::BaseRequest do
  subject(:request) { described_class.new(generate_image_request) }

  let(:generate_image_request) { build_stubbed :generate_image_request, prompts:, options: opts }
  let(:prompt) { build :prompt, text: 'prompt text', weight: 1 }
  let(:negative_prompt) { build :prompt, text: 'negative prompt text', weight: -1 }
  let(:prompts) { [prompt, negative_prompt] }
  let(:opts) do
    {
      style: GenerativeImage::Stability::STYLE_PRESETS.sample,
      aspect_ratio: GenerativeImage::Stability::ASPECT_RATIOS.sample
    }
  end

  describe '#as_json' do
    context 'with options' do
      it 'returns the expected JSON structure' do
        expect(request.as_json).to eq(prompt: 'prompt text',
                                      negative_prompt: 'negative prompt text',
                                      style_preset: opts.fetch(:style),
                                      aspect_ratio: opts.fetch(:aspect_ratio),
                                      output_format: 'png',
                                      seed: 0)
      end
    end
  end

  describe '#path' do
    it 'is nil' do
      expect(request.path).to be_nil
    end
  end
end
