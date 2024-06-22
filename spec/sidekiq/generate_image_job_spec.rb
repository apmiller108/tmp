require 'rails_helper'
require 'vips'
require 'tempfile'

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
    let(:image) { file_fixture('image.png').read }
    let(:response) { instance_double GenerativeImage::Stability::TextToImageResponse, image:, image_present?: true }

    before do
      allow(GenerateImageRequest).to receive(:find).with(request.id).and_return(request)
      allow(GenerativeImage).to receive(:new).and_return(generative_image)
      allow(MyChannel).to receive(:broadcast_to)
      allow(ViewComponentBroadcaster).to receive(:call)
      allow(request.image).to receive(:attach)
    end

    context 'when the image was succesfully generated' do
      before do
        allow(generative_image).to receive(:text_to_image).with(params).and_return(response)
      end

      it 'attaches the original image to the request' do
        perform
        expect(request.image).to(
          have_received(:attach).with(io: kind_of(Tempfile),
                                      filename: "#{request.image_name}.png",
                                      content_type: 'image/png')
        )
      end

      it 'broadcasts the webp converted image' do
        perform
        expect(MyChannel).to(
          have_received(:broadcast_to).with(request.user,
                                            { generate_image: { image_name: request.image_name,
                                                                image: kind_of(String),
                                                                content_type: 'image/webp',
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
                                    content_type: nil, error: true } })
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
