require 'rails_helper'

RSpec.describe GenerativeText do
  let(:generate_text_request) { build_stubbed :generate_text_request }
  let(:aws_client) { instance_double(GenerativeText::AWS::Client) }
  let(:anthropic_client) { instance_double(GenerativeText::Anthropic::Client) }

  describe '.summary_prompt_for' do
    it 'calls Helpers.transcription_summary_prompt' do
      transcription = build_stubbed :transcription
      expect(GenerativeText::Helpers).to receive(:transcription_summary_prompt).with(transcription)
      described_class.summary_prompt_for(transcription:)
    end
  end

  describe '.client_for' do
    context 'when vendor is AWS' do
      let(:generate_text_request) { build_stubbed :generate_text_request, :with_aws_model }

      it 'returns AWS::Client' do
        expect(described_class.client_for(generate_text_request)).to eq(GenerativeText::AWS::Client)
      end
    end

    context 'when vendor is Anthropic' do
      let(:generate_text_request) { build_stubbed :generate_text_request, :with_anthropic_model }

      it 'returns Anthropic::Client' do
        expect(described_class.client_for(generate_text_request)).to eq(GenerativeText::Anthropic::Client)
      end
    end
  end

  describe '#invoke_model_stream' do
    subject(:generative_text) { described_class.new }

    let(:generate_text_request) { build_stubbed :generate_text_request, :with_aws_model }
    let(:block) { -> {} }

    it 'creates client and calls invoke_model_stream' do
      allow(GenerativeText::AWS::Client).to receive(:new).and_return(aws_client)
      expect(aws_client).to receive(:invoke_model_stream).with(generate_text_request)
      generative_text.invoke_model_stream(generate_text_request)
    end
  end

  describe '#invoke_model' do
    subject(:generative_text) { described_class.new }

    let(:response) { instance_double(GenerativeText::Anthropic::InvokeModelResponse) }
    let(:generate_text_request) { build_stubbed :generate_text_request, :with_anthropic_model }

    it 'creates client and calls invoke_model' do
      allow(GenerativeText::Anthropic::Client).to receive(:new).and_return(anthropic_client)
      allow(anthropic_client).to receive(:invoke_model)
        .with(generate_text_request)
        .and_return(response)

      expect(generative_text.invoke_model(generate_text_request)).to eq(response)
    end
  end

  describe 'DEFAULT_MODEL' do
    it 'finds model with api_name claude-3-5-haiku-latest' do
      expect(described_class::DEFAULT_MODEL).to eq(
        described_class::MODELS.find { |m| m.api_name == 'claude-3-5-haiku-latest' }
      )
    end
  end
end
