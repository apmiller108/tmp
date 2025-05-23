require 'rails_helper'

RSpec.describe GenerateConversationTitleJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    let(:conversation) { build_stubbed(:conversation, user:) }
    let(:user) { build_stubbed(:user) }
    let(:request) { build_stubbed(:generate_text_request) }
    let(:generative_text) { instance_double(GenerativeText) }
    let(:response) do
      instance_double(GenerativeText::Anthropic::InvokeModelResponse, data: 'response data', content: 'New Title')
    end
    let(:prompt) { 'conversation title prompt' }

    before do
      allow(Conversation).to receive(:find).with(conversation.id).and_return(conversation)
      allow(GenerativeText::Helpers).to receive(:conversation_title_prompt).with(conversation).and_return(prompt)
      allow(GenerateTextRequest).to receive(:create!).and_return(request)
      allow(GenerativeText).to receive(:new).and_return(generative_text)
      allow(generative_text).to receive(:invoke_model).with(request).and_return(response)
      allow(Turbo::StreamsChannel).to receive(:broadcast_action_to)
      allow(Rails.logger).to receive(:warn)
      allow(ApplicationHelper).to receive(:list_dom_id).with(conversation).and_return('conversation_1')
      allow(request).to receive(:update!)
      allow(conversation).to receive(:update!)
    end

    it 'creates a generate text request' do
      job.perform(conversation.id)
      expect(GenerateTextRequest).to have_received(:create!).with(
        markdown_format: false,
        user:,
        prompt:,
        temperature: 0.2,
        model: GenerativeText::SUMMARY_MODEL.api_name
      )
    end

    it 'invokes the generative text model' do
      job.perform(conversation.id)
      expect(generative_text).to have_received(:invoke_model).with(request)
    end

    it 'updates the request with the response' do
      job.perform(conversation.id)
      expect(request).to have_received(:update!).with(
        response: response.data,
        status: GenerateTextRequest.statuses[:completed]
      )
    end

    it 'updates the conversation with the new title' do
      job.perform(conversation.id)
      expect(conversation).to have_received(:update!).with(title: response.content)
    end

    it 'broadcasts the title form' do
      job.perform(conversation.id)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).with(
        [user, TurboStreams::STREAMS[:main]],
        target: 'conversation-title',
        partial: 'conversations/title_form',
        locals: { conversation: },
        action: :replace
      )
    end

    it 'broadcasts the list item' do
      job.perform(conversation.id)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_action_to).with(
        [user, TurboStreams::STREAMS[:main]],
        target: 'conversation_1',
        partial: 'conversations/list_item',
        formats: [:turbo_stream],
        locals: { conversation: },
        action: :replace
      )
    end

    context 'when an error occurs' do
      before do
        allow(GenerativeText).to receive(:new).and_raise(StandardError.new('Test error'))
      end

      # it 'broadcasts a flash message to the user' do
      #   job.perform(conversation.id)
      #   expect(job).to have_received(:broadcast_flash_to_user).with(
      #     message: 'Unable to generate title',
      #     user: user
      #   )
      # end

      it 'logs the error' do
        job.perform(conversation.id)
        expect(Rails.logger).to have_received(:warn).with("GenerateConversationTitleJob: Test error")
      end
    end
  end
end
