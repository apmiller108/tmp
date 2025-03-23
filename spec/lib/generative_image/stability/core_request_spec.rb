require 'rails_helper'

RSpec.describe GenerativeImage::Stability::CoreRequest do
  subject(:request) { described_class.new(generate_image_request) }

  let(:generate_image_request) { build_stubbed :generate_image_request }

  it { is_expected.to be_a GenerativeImage::Stability::BaseRequest }

  describe '#path' do
    it 'returns the CORE_GENERATION_ENDPOINT' do
      expect(request.path).to eq(GenerativeImage::Stability::CORE_GENERATION_ENDPOINT)
    end
  end
end
