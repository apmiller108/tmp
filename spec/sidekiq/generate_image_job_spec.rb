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
    let(:base64) { 'base64 string of png' }
    let(:response) { instance_double GenerativeImage::Stability::TextToImageResponse, base64:, image_present?: true }

    before do
      allow(GenerateImageRequest).to receive(:find).with(request.id).and_return(request)
      allow(GenerativeImage).to receive(:new).and_return(generative_image)
      allow(MyChannel).to receive(:broadcast_to)
      allow(ViewComponentBroadcaster).to receive(:call)
    end

    context 'when the image was succesfully generated' do
      before do
        allow(generative_image).to receive(:text_to_image).with(params).and_return(response)
      end

      it 'broadcasts the image' do
        perform
        expect(MyChannel).to(
          have_received(:broadcast_to).with(request.user,
                                            { generate_image: { image_name: request.image_name, image: base64,
                                                                error: nil } })
        )
      end
    end

    context 'when the image generation failed' do
      before do
        allow(generative_image).to receive(:text_to_image).with(params).and_raise(GenerativeImage::InvalidRequestError)
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs the error' do
        perform
        expect(Rails.logger).to have_received(:warn).with('GenerateImageJob: GenerativeImage::InvalidRequestError : ')
      end

      it 'broadcasts the error payload' do
        perform
        expect(MyChannel).to have_received(:broadcast_to)
          .with(request.user,
                { generate_image: { image_name: request.image_name, image: nil,
                                    error: true } })
      end

      it 'broadcasts the flash message' do
        perform
        expect(ViewComponentBroadcaster).to have_received(:call)
          .with([request.user, TurboStreams::STREAMS[:memos]],
                component: kind_of(FlashMessageComponent), action: :replace)
      end
    end

    context 'with a standard error' do
      before do
        allow(generative_image).to receive(:text_to_image).with(params).and_raise(StandardError)
        allow(Rails.logger).to receive(:warn)
      end

      it 'broadcasts the flash message' do
        perform
        expect(ViewComponentBroadcaster).to have_received(:call)
          .with([request.user, TurboStreams::STREAMS[:memos]],
                component: kind_of(FlashMessageComponent), action: :replace)
      end

      it 'logs the error' do
        perform
        expect(Rails.logger).to have_received(:warn).with('GenerateImageJob: StandardError : ')
      end
    end
  end
end
