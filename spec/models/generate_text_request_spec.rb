require 'rails_helper'

RSpec.describe GenerateTextRequest, type: :model do
  describe '#conversation' do
    subject(:request) do
      build(:generate_text_request, conversation:)
    end

    context 'when conversation exists' do
      let(:conversation) { build_stubbed(:conversation) }

      it 'returns the associated conversation' do
        expect(request.conversation).to eq(conversation)
      end
    end

    context 'when conversation is nil' do
      let(:conversation) { nil }

      it 'returns a NullConversation instance' do
        expect(request.conversation).to be_a(NullConversation)
      end
    end
  end

  describe '#system_message' do
    subject(:request) do
      build(:generate_text_request, generate_text_preset: preset, markdown_format:)
    end

    let(:markdown_format) { true }
    let(:preset) { build(:generate_text_preset, system_message: 'Custom system message') }

    it 'combines markdown format message with preset system message' do
      expected_message = "#{GenerativeText::Helpers.markdown_sys_msg}\nCustom system message"
      expect(request.system_message).to eq(expected_message)
    end

    context 'when preset is nil' do
      let(:preset) { nil }

      it 'returns only the markdown format message' do
        expect(request.system_message).to eq(GenerativeText::Helpers.markdown_sys_msg)
      end

      context 'when markdown_format is false' do
        let(:markdown_format) { false }

        it 'is blank' do
          expect(request.system_message).to be_blank
        end
      end
    end

    context 'when markdown_format is false' do
      let(:markdown_format) { false }

      it 'returns only the markdown format message' do
        expect(request.system_message).to eq(preset.system_message)
      end
    end
  end

  describe '#response' do
    context 'when response data exists' do
      context 'with an Anthropic model' do
        subject(:request) { build(:generate_text_request, :with_response, :with_anthropic_model) }

        it 'returns an Anthropic::InvokeModelResponse instance' do
          expect(request.response).to be_a(GenerativeText::Anthropic::InvokeModelResponse)
        end
      end

      context 'with an AWS model' do
        subject(:request) { build(:generate_text_request, :with_response, :with_aws_model) }

        it 'returns an AWS::InvokeModelResponse instance' do
          expect(request.response).to be_a(GenerativeText::AWS::InvokeModelResponse)
        end
      end
    end

    context 'when response is nil' do
      subject(:request) { build(:generate_text_request, response: nil) }

      it 'returns nil' do
        expect(request.response).to be_nil
      end
    end
  end

  describe '#response_token_count' do
    context 'when request is completed' do
      subject(:request) do
        build(:generate_text_request, :with_response, :completed)
      end

      let(:response_obj) { instance_double(GenerativeText::Anthropic::InvokeModelResponse, token_count: 100) }

      before do
        allow(GenerativeText::Anthropic::InvokeModelResponse).to receive(:new).and_return(response_obj)
      end

      it 'returns the token count from the response' do
        expect(request.response_token_count).to eq(100)
      end
    end

    context 'when request is not completed' do
      subject(:request) do
        build(:generate_text_request, status: described_class.statuses.values.reject { |s| s == 'completed' }.sample)
      end

      it 'returns 0' do
        expect(request.response_token_count).to eq(0)
      end
    end
  end

  describe '#to_turn' do
    subject(:request) do
      build(:generate_text_request)
    end

    it 'delegates to GenerativeText::Anthropic::Turn' do
      expect(GenerativeText::Anthropic::Turn).to receive(:for).with(request)
      request.to_turn
    end
  end

  describe '#model' do
    let(:model) { GenerativeText::MODELS.sample }

    it 'returns the matching model from GenerativeText::MODELS' do
      request = build(:generate_text_request, model: model.api_name)
      expect(request.model).to eq(model)
    end
  end
end
