require 'rails_helper'

RSpec.describe LLMService do
  describe '#initialize' do
    it 'sets the default AWS client' do
      llm_service = described_class.new
      expect(llm_service.client).to be_an_instance_of(LLMService::AWS::Client)
    end

    it 'sets a custom client if provided' do
      custom_client = double('CustomClient') # rubocop:disable RSpec/VerifiedDoubles
      llm_service = described_class.new(custom_client)
      expect(llm_service.client).to eq(custom_client)
    end
  end

  describe '#invoke_model_stream' do
    it 'calls the client method with the provided prompt and options' do
      prompt = 'Generate something interesting.'
      options = { max_tokens: 100 }

      client_double = instance_double(LLMService::AWS::Client)
      allow(client_double).to receive(:invoke_model_stream)

      llm_service = described_class.new(client_double)
      llm_service.invoke_model_stream(prompt:, **options)

      expect(client_double).to have_received(:invoke_model_stream).with(prompt:, **options)
    end
  end
end
