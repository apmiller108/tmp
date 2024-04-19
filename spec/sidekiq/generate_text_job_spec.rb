require 'rails_helper'

RSpec.describe GenerateTextJob, type: :job do
  describe 'sidekiq_options' do
    subject { described_class.sidekiq_options }

    it { is_expected.to include('retry' => false) }
  end

  describe '#perform' do
    subject(:perform) { described_class.new.perform(generate_text_request.id) }

    let(:generate_text_request) { build_stubbed :generate_text_request, :with_generate_text_preset }
    let(:response) do
      instance_double(GenerativeText::AWS::Client::InvokeModelResponse, content: Faker::Lorem.paragraph)
    end
    let(:generative_text) { instance_double(GenerativeText, invoke_model: response) }

    before do
      allow(GenerateTextRequest).to receive(:find).and_return(generate_text_request)
      allow(MyChannel).to receive(:broadcast_to)
      allow(ViewComponentBroadcaster).to receive(:call)
      allow(GenerativeText).to receive(:new).and_return(generative_text)
    end

    context 'when the text is generated successfully' do
      it 'invokes the model with the proper params' do
        perform
        expect(generative_text).to have_received(:invoke_model)
          .with(prompt: generate_text_request.prompt,
                temperature: generate_text_request.temperature,
                system_message: generate_text_request.system_message,
                max_tokens: 500)
      end

      it 'broadcasts the text content' do
        perform
        expect(MyChannel).to have_received(:broadcast_to).with(generate_text_request.user,
                                                               generate_text: { text_id: generate_text_request.text_id,
                                                                                content: response.content, error: nil })
      end
    end

    context 'when the text generation fails' do
      before do
        allow(generative_text).to receive(:invoke_model).and_raise(GenerativeText::InvalidRequestError)
        allow(Rails.logger).to receive(:warn)
      end

      it 'logs the error' do
        perform
        expect(Rails.logger).to have_received(:warn).with('GenerateTextJob: GenerativeText::InvalidRequestError : ')
      end

      it 'broadcasts an error response' do
        perform
        expect(MyChannel).to have_received(:broadcast_to).with(generate_text_request.user,
                                                               generate_text: { text_id: generate_text_request.text_id,
                                                                                content: nil, error: true })
      end

      it 'broadcasts a flash message' do
        perform
        expect(ViewComponentBroadcaster).to(
          have_received(:call).with([generate_text_request.user, TurboStreams::STREAMS[:memos]],
                                    component: kind_of(FlashMessageComponent), action: :update)
        )
      end
    end
  end
end
