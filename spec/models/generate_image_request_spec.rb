require 'rails_helper'

RSpec.describe GenerateImageRequest, type: :model do
  describe '#parameterize' do
    let(:prompt1) { build_stubbed :prompt }
    let(:prompt1_params) { { text: 'prompt1', weight: 1 } }
    let(:prompt2) { build_stubbed :prompt }
    let(:prompt2_params) { { text: 'prompt2', weight: -1 } }

    let(:request) do
      described_class.new(
        style: GenerativeImage::Stability::STYLE_PRESETS.sample,
        dimensions: GenerativeImage::Stability::DIMENSIONS.sample,
        prompts: [prompt1, prompt2]
      )
    end

    before do
      allow(prompt1).to receive(:parameterize).and_return(prompt1_params)
      allow(prompt2).to receive(:parameterize).and_return(prompt2_params)
    end

    it 'returns a hash with style, dimensions, and prompts' do
      expected_hash = {
        style: request.style,
        dimensions: request.dimensions,
        prompts: [prompt1_params, prompt2_params]
      }

      expect(request.parameterize).to eq(expected_hash)
    end
  end
end
