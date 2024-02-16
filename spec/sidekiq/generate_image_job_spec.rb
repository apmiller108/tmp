require 'rails_helper'

RSpec.describe GenerateImageJob, type: :job do
  describe 'sidekiq_options' do
    subject { described_class.sidekiq_options }

    it { is_expected.to include('retry' => false) }
  end

  describe '#perform' do
    subject(:perform) { described_class.new.perform(request.id) }

    let(:request) { build_stubbed :generate_image_request }
    let(:params) { request.parameterize }
    let(:generative_image) { instance_double GenerativeImage }
    let(:image) { double }

    before do
      allow(GenerateImageRequest).to receive(:find).with(request.id).and_return(request)
      allow(GenerativeImage).to receive(:new).and_return(generative_image)
      allow(MyChannel).to receive(:broadcast_to)
      allow(ViewComponentBroadcaster).to receive(:call)
    end

    context 'when the image was succesfully generated' do
      before do
        allow(generative_image).to receive(:text_to_image).with(params).and_return(image)
      end

      it 'broadcasts the image' do
      end
    end

    context 'when the image generation failed' do
      before do
        allow(generative_image).to receive(:text_to_image).with(params).and_raise(GenerativeImage::InvalidRequestError)
      end

      it 'logs the error' do
      end

      it 'broadcasts the error payload' do
      end

      it 'broadcasts the flash message' do
      end
    end
  end
end
