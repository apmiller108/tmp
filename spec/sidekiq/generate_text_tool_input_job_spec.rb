require 'rails_helper'

RSpec.describe GenerateTextToolInputJob do
  subject(:job) { described_class.new }

  let(:user) { create(:user, :with_setting) }
  let(:conversation) { create(:conversation, user:) }

  describe '#perform' do
    before do
      allow(GenerateImageRequestForm).to receive(:new).and_call_original
    end

    context 'when response is not a tool use' do
      let(:generate_text_request) do
        create(:generate_text_request, :with_response, user:, conversation:)
      end

      it 'returns early' do
        job.perform(generate_text_request.id)
        expect(GenerateImageRequestForm).not_to have_received(:new)
      end

      it 'does not enqueue a job' do
        expect { job.perform(generate_text_request.id) }.not_to change(Conversations::GenerateImageJob.jobs, :size)
      end
    end

    context 'when response is a tool use' do
      let(:generate_text_request) do
        create(:generate_text_request, :with_tool_use_response, user:, conversation:)
      end

      it 'instantiates the form with the proper attributes' do
        job.perform(generate_text_request.id)
        expect(GenerateImageRequestForm).to(
          have_received(:new).with(
            {
              'user' => user,
              'conversation' => conversation,
              'generate_text_request' => generate_text_request,
              'aspect_ratio' => '16:9',
              'prompt' => 'image prompt',
              'negative_prompt' => 'negative prompt',
              'style' => 'fantasy-art'
            }
          )
        )
      end

      context 'when form submission succeeds' do
        it 'creates a generate image request' do
          expect { job.perform(generate_text_request.id) }.to change(conversation.generate_image_requests, :count).by(1)
        end

        it 'enqueues generate image job' do
          expect { job.perform(generate_text_request.id) }.to change(Conversations::GenerateImageJob.jobs, :size)
        end
      end

      context 'when form submission fails' do
        let(:form) { GenerateImageRequestForm.new(prompt: nil) }

        before do
          allow(GenerateImageRequestForm).to receive(:new).and_return form
          allow(Rails.logger).to receive(:warn)
          allow(ViewComponentBroadcaster).to receive(:call)
          job.perform(generate_text_request.id)
        end

        it 'broadcasts error flash' do
          expect(ViewComponentBroadcaster).to(
            have_received(:call).with(
              [user, TurboStreams::STREAMS[:main]],
              component: kind_of(FlashMessageComponent),
              action: :update
            )
          )
        end

        it 'logs a warning' do
          expect(Rails.logger).to have_received(:warn)
            .with("GenerateTextToolInputJob: form_errors : #{form.errors.full_messages}")
        end
      end
    end

    context 'when an error occurs' do
      before do
        allow(GenerateTextRequest).to receive(:find).and_raise(StandardError.new('error message'))
        allow(Rails.logger).to receive(:warn)
        allow(ViewComponentBroadcaster).to receive(:call)
        job.perform(99)
      end

      it 'logs the error message as a warning' do
        expect(Rails.logger).to have_received(:warn)
          .with('GenerateTextToolInputJob: error message : generate_text_request_id: 99')
      end
    end
  end
end
