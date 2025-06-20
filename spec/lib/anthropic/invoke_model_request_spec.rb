require 'rails_helper'

RSpec.describe Anthropic::InvokeModelRequest do
  subject(:request) { described_class.new(generate_text_request) }

  let(:conversation) { nil }
  let(:generate_text_request) { build_stubbed :generate_text_request, conversation:, markdown_format: }
  let(:markdown_format) { false }

  describe '#to_h' do
    it 'returns a hash with proper attributes' do
      expect(request.to_h).to eq(
        {
          max_tokens: generate_text_request.model.max_tokens,
          messages: [{ 'content' => [{ 'text' => generate_text_request.prompt,
                                       'type' => 'text' }], 'role' => 'user' }],
          model: generate_text_request.model.api_name,
          stream: false,
          system: '',
          temperature: generate_text_request.temperature
        }
      )
    end

    context 'with a conversation' do
      let(:conversation) { build_stubbed :conversation }

      it 'returns a hash with proper attributes' do
        expect(request.to_h).to eq(
          {
            max_tokens: generate_text_request.model.max_tokens,
            messages: [{ 'content' => [{ 'text' => generate_text_request.prompt,
                                         'type' => 'text' }], 'role' => 'user' }],
            model: generate_text_request.model.api_name,
            stream: false,
            system: '',
            temperature: generate_text_request.temperature
          }
        )
      end

      context 'with tools' do
        let(:conversation) { build_stubbed :conversation, tool_types: ['image'] }

        it 'returns a hash with proper attributes' do
          expect(request.to_h).to include(
            max_tokens: generate_text_request.model.max_tokens,
            messages: [{ 'content' => [{ 'text' => generate_text_request.prompt,
                                         'type' => 'text' }], 'role' => 'user' }],
            model: generate_text_request.model.api_name,
            stream: false,
            system: '',
            temperature: generate_text_request.temperature,
            tool_choice: { type: :auto }
          )
        end

        it 'contains the proper tools' do
          expect(request.to_h[:tools].map(&:id)).to eq LlmTool.where(tool_type: conversation.tool_types).map(&:id)
        end
      end
    end
  end
end
