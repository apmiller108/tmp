require 'rails_helper'

describe GenerativeImage::Stability::TextToImageRequest do
  describe '#as_json' do
    let(:prompts) { build_list :prompt, 3 }

    context 'with options' do
      let(:generate_image_request) { build_stubbed(:generate_image_request, prompts:) }
      let(:args) { generate_image_request.parameterize }

      it 'returns a hash with the proper kv pairs' do
        expect(described_class.new(**args).as_json).to eq({
          text_prompts: args[:prompts],
          style_preset: args[:style],
          height: args[:dimensions].split('x')[1].to_i,
          width: args[:dimensions].split('x')[0].to_i,
          cfg_scale: 10,
          samples: 1,
          seed: 0,
          steps: 30
        })
      end
    end

    context 'with defaults' do
      let(:generate_image_request) { build_stubbed(:generate_image_request, prompts:, style: nil) }
      let(:args) { generate_image_request.parameterize }

      it 'returns a hash with the proper kv pairs' do
        expect(described_class.new(**args).as_json).to eq({
          text_prompts: args[:prompts],
          style_preset: GenerativeImage::Stability::DEFAULT_STYLE,
          height: args[:dimensions].split('x')[1].to_i,
          width: args[:dimensions].split('x')[0].to_i,
          cfg_scale: 10,
          samples: 1,
          seed: 0,
          steps: 30
        })
      end
    end
  end
end
