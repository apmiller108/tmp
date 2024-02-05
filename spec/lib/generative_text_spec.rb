require 'rails_helper'

RSpec.describe GenerativeText do
  describe '#initialize' do
    it 'sets the default AWS client' do
      generative_text = described_class.new
      expect(generative_text.client).to be_an_instance_of(GenerativeText::AWS::Client)
    end

    it 'sets a custom client if provided' do
      custom_client = double('CustomClient') # rubocop:disable RSpec/VerifiedDoubles
      generative_text = described_class.new(custom_client)
      expect(generative_text.client).to eq(custom_client)
    end
  end

  describe '#invoke_model_stream' do
    it 'calls the client method with the provided prompt and options' do
      prompt = 'Generate something interesting.'
      options = { max_tokens: 100 }

      client_double = instance_double(GenerativeText::AWS::Client)
      allow(client_double).to receive(:invoke_model_stream)

      generative_text = described_class.new(client_double)
      generative_text.invoke_model_stream(prompt:, **options)

      expect(client_double).to have_received(:invoke_model_stream).with(prompt:, **options)
    end
  end
end
