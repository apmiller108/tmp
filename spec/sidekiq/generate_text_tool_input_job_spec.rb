require 'rails_helper'

RSpec.describe GenerateTextToolInputJob do
  subject(:job) { described_class.new }

  let(:user) { create(:user, :with_setting) }
  let(:input) do
    {
      'id' => 'toolu_0196KvCx6JumrjS1g6qvN14H',
      'name' => 'GenerateImage',
      'type' => 'tool_use',
      'input' => {
        'options' => { 'style' => 'fantasy-art', 'aspect_ratio' => '16:9' },
        'prompts' => { 'prompt' => 'image prompt', 'negative_prompt' => 'negative prompt' }
      }
    }
  end

  describe '#perform' do
    let(:handler) { instance_double LlmTool::Handlers::GenerateImage }

    before do
      allow(LlmTool).to receive(:handler_for).with(input).and_return(handler)
      allow(handler).to receive(:call).with(generate_text_request).and_return(true)
    end

    context 'when response is not a tool use' do
      let(:generate_text_request) do
        create(:generate_text_request, :with_response, user:)
      end

      it 'returns early' do
        job.perform(generate_text_request.id)
        expect(LlmTool).not_to have_received(:handler_for)
      end
    end

    context 'when response is a tool use' do
      let(:generate_text_request) do
        create(:generate_text_request, :with_tool_use_response, user:)
      end

      it 'calls the tool handler' do
        job.perform(generate_text_request.id)
        expect(handler).to have_received(:call).with(generate_text_request)
      end

      context 'when the handler fails' do
        before do
          allow(handler).to receive(:call).with(generate_text_request).and_return(false)
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
            .with(a_string_matching(/GenerateTextToolInputJob:.+failed/))
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
