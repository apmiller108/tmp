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
  let(:aws_client) do
    instance_double(Aws::BedrockRuntime::Client, invoke_model: nil, invoke_model_with_response_stream: nil)
  end

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

  describe '#invoke_model' do
    subject(:client) { described_class.new }

    let(:prompt) { 'List 18.5 fruits' }
    let(:params) { { a: 1, b: 2 } }
    let(:request) { instance_double LLMService::AWS::Client::InvokeModelRequest, to_h: request_hash }
    let(:request_hash) { double }
    let(:response_string) { double }
    let(:body) { instance_double StringIO, read: response_string }
    let(:client_response) { instance_double Aws::BedrockRuntime::Types::InvokeModelResponse, body: }
    let(:response) { instance_double LLMService::AWS::Client::InvokeModelResponse }

    before do
      allow(LLMService::AWS::Client::InvokeModelRequest).to receive(:new).with(prompt:, **params).and_return(request)
      allow(aws_client).to receive(:invoke_model).with(request_hash).and_return(client_response)
      allow(LLMService::AWS::Client::InvokeModelResponse).to receive(:new).with(response_string).and_return(response)
    end

    it 'returns the InvokeModelResponse object' do
      expect(client.invoke_model(prompt:, **params)).to eq response
    end
  end

  describe '#invoke_model_stream' do
    subject(:client) { described_class.new }

    let(:prompt) { 'tell me something awesme' }
    let(:handler_proc) { proc {} }
    let(:handler) { instance_double(LLMService::AWS::Client::EventStreamHandler, to_proc: handler_proc) }
    let(:request) { instance_double(LLMService::AWS::Client::InvokeModelRequest, to_h: request_params) }
    let(:request_params) { { b: 2 } }
    let(:params) { { a: 1 } }

    before do
      allow(LLMService::AWS::Client::EventStreamHandler).to receive(:new).and_return(handler)
      allow(LLMService::AWS::Client::InvokeModelRequest).to(
        receive(:new).with(prompt:, **params.merge(event_stream_handler: handler_proc)).and_return(request)
      )
    end

    it 'delegates to the aws client with the proper params' do
      block = proc {}
      client.invoke_model_stream(prompt:, **params, &block)

      expect(aws_client).to have_received(:invoke_model_with_response_stream).with(request_params)
    end
  end
end
