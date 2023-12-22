require 'rails_helper'

RSpec.describe TranscriptionService::AWS::Client::BatchTranscription do
  let(:aws_client_response) { double }
  let(:aws_client) { instance_double Aws::TranscribeService::Client, start_transcription_job: aws_client_response }
  let(:client) { TranscriptionService::AWS::Client.new }
  let(:blob) { build_stubbed :active_storage_blob }
  let(:options) { { a: 1 } }
  let(:params) { double }
  let(:request) { instance_double TranscriptionService::AWS::BatchTranscriptionRequest, params: }
  let(:response) { instance_double TranscriptionService::AWS::BatchTranscriptionResponse }

  before do
    allow(Aws::TranscribeService::Client).to receive(:new).and_return(aws_client)
    allow(aws_client).to receive(:start_transcription_job).and_return(aws_client_response)
    allow(TranscriptionService::AWS::BatchTranscriptionRequest).to receive(:new).and_return(request)
    allow(TranscriptionService::AWS::BatchTranscriptionResponse).to receive(:new).and_return(response)
  end

  describe '.call' do
    subject(:call) { described_class.call(client, blob, **options) }

    it 'returns self' do
      expect(call).to be_a described_class
    end

    it 'creates the request object' do
      call
      expect(TranscriptionService::AWS::BatchTranscriptionRequest).to have_received(:new).with(blob, **options)
    end

    it 'sets @request' do
      expect(call.request).to eq request
    end

    it 'calls start_trascription_job on the client with the request params' do
      call
      expect(aws_client).to have_received(:start_transcription_job).with(params)
    end

    it 'creates the response object with the raw client response' do
      call
      expect(TranscriptionService::AWS::BatchTranscriptionResponse).to have_received(:new).with(aws_client_response)
    end

    it 'sets @response' do
      expect(call.response).to eq response
    end
  end
end
