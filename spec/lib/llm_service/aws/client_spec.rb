require 'rails_helper'
require 'aws-sdk-bedrockruntime'

RSpec.describe LLMService::AWS::Client do
  let(:aws_config) do
    {
      region: 'us-east-1',
      access_key_id: 'your_access_key_id',
      secret_access_key: 'your_secret_access_key'
    }
  end
  let(:credentials) { instance_double(Aws::Credentials) }
  let(:aws_client) { instance_double(Aws::BedrockRuntime::Client, invoke_model: nil) }

  before do
    allow(Rails.application.credentials).to receive(:fetch).with(:aws).and_return(aws_config)
    allow(Aws::Credentials).to receive(:new).with(aws_config[:access_key_id], aws_config[:secret_access_key])
                                            .and_return(credentials)
    allow(Aws::BedrockRuntime::Client).to receive(:new).and_return(aws_client)
  end

  describe '#initialize' do
    it 'creates an instance of Aws::BedrockRuntime::Client' do
      described_class.new
      expect(Aws::BedrockRuntime::Client).to have_received(:new).with(
        region: aws_config[:region],
        credentials:
      )
    end
  end

  describe 'delegated methods' do
    it 'delegates missing methods to Aws::BedrockRuntime::Client' do
      client = described_class.new
      client.invoke_model
      expect(aws_client).to have_received(:invoke_model)
    end
  end
end
