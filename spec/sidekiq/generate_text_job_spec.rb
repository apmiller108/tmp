require 'rails_helper'

RSpec.describe GenerateTextJob, type: :job do
  describe 'sidekiq_options' do
    subject { described_class.sidekiq_options }

    it { is_expected.to include('retry' => 1) }
  end

  describe '#perform' do
    subject(:perform) { described_class.new.perform(generate_text_request.id) }

    let(:generate_text_request) { build_stubbed :generate_text_request, :with_preset, conversation: }
    let(:user) { generate_text_request.user }
    let(:conversation) { build_stubbed :conversation }
    let(:response_data) { { 'content' => 'response data' } }
    let(:response) do
      instance_double(GenerativeText::Anthropic::InvokeModelResponse,
                      content: Faker::Lorem.paragraph, data: response_data)
    end
    let(:prompt_form_component) { instance_double PromptFormComponent }
    let(:conversation_turn_component) { instance_double ConversationTurnComponent }
    let(:generative_text) { instance_double(GenerativeText, invoke_model: response) }

    before do
      allow(GenerateTextRequest).to receive(:find).and_return(generate_text_request)
      allow(MyChannel).to receive(:broadcast_to)
      allow(ViewComponentBroadcaster).to receive(:call)
      allow(GenerativeText).to receive(:new).and_return(generative_text)
      allow(PromptFormComponent).to receive(:new).with(conversation:).and_return(prompt_form_component)
      allow(ConversationTurnComponent).to receive(:new).with(generate_text_request:)
                                                       .and_return(conversation_turn_component)
      allow(generate_text_request).to receive(:update!)
      allow(generate_text_request).to receive(:in_progress!)
      allow(generate_text_request).to receive(:failed!)
      allow(conversation).to receive(:reload).and_return(conversation)
    end

    context 'when the text is generated successfully' do
      it 'marks the request as in_progress' do
        perform
        expect(generate_text_request).to have_received(:in_progress!)
      end

      it 'broadcasts the text content' do
        perform
        expect(MyChannel).to(
          have_received(:broadcast_to).with(
            user,
            generate_text: { 'text_id' => generate_text_request.text_id,
                             'conversation_id' => conversation.id,
                             'user_id' => user.id,
                             content: response.content,
                             error: nil }
          )
        )
      end

      it 'updates the request' do
        perform
        expect(generate_text_request).to have_received(:update!).with(response: response_data, status: 'completed')
      end

      it 'broadcasts the ConversationTurnComponent' do
        perform
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with([user, TurboStreams::STREAMS[:main]],
                                    component: conversation_turn_component, action: :replace)
        )
      end

      it 'broadcasts the PromptFormComponent' do
        perform
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with([user, TurboStreams::STREAMS[:main]],
                                    component: prompt_form_component, action: :replace)
        )
      end
    end

    describe '.on_retries_exhausted' do
      subject(:on_retries_exhausted) { described_class.on_retries_exhausted(generate_text_request.id) }

      it 'marks the request as failed' do
        on_retries_exhausted
        expect(generate_text_request).to have_received(:failed!)
      end

      it 'broadcasts the ConversationTurnComponent' do
        on_retries_exhausted
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with([user, TurboStreams::STREAMS[:main]],
                                    component: conversation_turn_component, action: :replace)
        )
      end

      it 'broadcasts an error response' do
        on_retries_exhausted
        expect(MyChannel).to have_received(:broadcast_to).with(user,
                                                               generate_text: { text_id: generate_text_request.text_id,
                                                                                content: nil, error: true })
      end

      it 'broadcasts a flash message' do
        on_retries_exhausted
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with([generate_text_request.user, TurboStreams::STREAMS[:main]],
                                    component: kind_of(FlashMessageComponent), action: :update)
        )
      end
    end
  end
end
