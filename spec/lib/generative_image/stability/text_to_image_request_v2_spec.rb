require 'spec_helper'

RSpec.describe GenerativeImage::Stability::TextToImageRequestV2 do
  subject(:request) { described_class.new(prompts:, **opts) }

  let(:prompt) { { 'text' => 'prompt text', 'weight' => 1 } }
  let(:negative_prompt) { { 'text' => 'negative prompt text', 'weight' => -1 } }
  let(:prompts) { [prompt, negative_prompt] }
  let(:opts) do
    {
      style: GenerativeImage::Stability::STYLE_PRESETS.sample,
      aspect_ratio: GenerativeImage::Stability::CORE_ASPECT_RATIOS.sample,
      seed: 123
    }
  end

  describe '#as_json' do
    context 'with options' do
      it 'returns the expected JSON structure' do
        expect(request.as_json).to eq(prompt: 'prompt text',
                                      negative_prompt: 'negative prompt text',
                                      style_preset: opts.fetch(:style),
                                      aspect_ratio: opts.fetch(:aspect_ratio),
                                      seed: opts.fetch(:seed))
      end
    end

    context 'with defaults' do
      xit 'returns the expected JSON structure' do
      end
    end

    context 'without a negative prompt' do
      xit 'returns the expected JSON structure' do
      end
    end
  end

  describe '#path' do
    it 'returns the CORE_GENERATION_ENDPOINT' do
      expect(request.path).to eq(GenerativeImage::Stability::CORE_GENERATION_ENDPOINT)
    end
  end
end
