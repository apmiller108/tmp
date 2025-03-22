require 'rails_helper'
require 'vips'
require 'tempfile'

RSpec.describe Conversations::GenerateImageJob, type: :job do
  describe 'sidekiq_options' do
    subject { described_class.sidekiq_options }

    it { is_expected.to include('retry' => false) }
  end

  describe '#perform' do
    subject(:perform) { described_class.new.perform(request.id) }

    let(:conversation_turn) { build_stubbed :conversation_turn }
    let(:request) { build_stubbed :generate_image_request, user:, conversation_turn: }
    let(:user) { build_stubbed :user }
    let(:generative_image) { instance_double GenerativeImage }
    let(:image) { file_fixture('image.png').read }
    let(:response) { instance_double GenerativeImage::Stability::ImageResponse, image:, image_present?: true }

    before do
      allow(request).to receive(:completed!)
      allow(request).to receive(:in_progress!)
      allow(request).to receive(:failed!)
      allow(GenerateImageRequest).to receive(:find).with(request.id).and_return(request)
      allow(GenerativeImage).to receive(:new).and_return(generative_image)
      allow(MyChannel).to receive(:broadcast_to)
      allow(ViewComponentBroadcaster).to receive(:call)
      allow(request.image).to receive(:attach)
    end

    context 'when the image was succesfully generated' do
      before do
        allow(generative_image).to receive(:perform_request).with(request).and_return(response)
        perform
      end

      it 'marks the request as in progress' do
        expect(request).to have_received(:in_progress!)
      end

      it 'attaches the original image to the request' do
        expect(request.image).to(
          have_received(:attach).with(io: kind_of(Tempfile),
                                      filename: "#{request.image_name}.png",
                                      content_type: 'image/png')
        )
      end

      it 'marks the request as completed' do
        expect(request).to have_received(:completed!)
      end

      it 'broadcasts the webp converted image' do
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with(
            [user, TurboStreams::STREAMS[:main]],
            component: kind_of(ConversationTurnComponent),
            action: :replace
          )
        )
      end

      it 'broadcasts the scrollspy nav item' do
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with(
            [user, TurboStreams::STREAMS[:main]],
            component: kind_of(ScrollspyNavItemComponent),
            action: :append,
            target: ScrollspyComponent::ITEMS_CONTAINER_ID
          )
        )
      end
    end

    context 'when the image generation failed' do
      before do
        allow(generative_image).to receive(:perform_request).with(request).and_raise(GenerativeImage::InvalidRequestError)
        allow(Rails.logger).to receive(:warn)
        perform
      end

      it 'marks the request as failed' do
        expect(request).to have_received(:failed!)
      end

      it 'logs the error' do
        expect(Rails.logger).to have_received(:warn)
          .with('Conversations::GenerateImageJob: GenerativeImage::InvalidRequestError : ')
      end

      it 'broadcasts the flash message' do
        expect(ViewComponentBroadcaster).to have_received(:call)
          .with([request.user, TurboStreams::STREAMS[:main]],
                component: kind_of(FlashMessageComponent), action: :update)
      end
    end

    context 'with a standard error' do
      before do
        allow(generative_image).to receive(:perform_request).with(request).and_raise(StandardError)
        allow(Rails.logger).to receive(:warn)
        perform
      end

      it 'marks the request as failed' do
        expect(request).to have_received(:failed!)
      end

      it 'broadcasts the flash message' do
        expect(ViewComponentBroadcaster).to have_received(:call)
          .with([request.user, TurboStreams::STREAMS[:main]],
                component: kind_of(FlashMessageComponent), action: :update)
      end

      it 'logs the error' do
        expect(Rails.logger).to have_received(:warn).with('Conversations::GenerateImageJob: StandardError : ')
      end
    end
  end
end
