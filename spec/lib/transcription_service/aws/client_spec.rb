require 'rails_helper'
require 'aws-sdk-transcribeservice'

describe TranscriptionService::AWS::Client do
  let(:aws_lib_client) { instance_double(Aws::TranscribeService::Client) }
  let(:aws_credentials) { instance_double(Aws::Credentials) }

  before do
    allow(Aws::Credentials).to(
      receive(:new).with(Rails.application.credentials.dig(:aws, :access_key_id),
                          Rails.application.credentials.dig(:aws, :secret_access_key))
                    .and_return(aws_credentials)
    )
    allow(Aws::TranscribeService::Client).to(
      receive(:new).with(region: Rails.application.credentials.dig(:aws, :region),
                          credentials: aws_credentials)
                    .and_return(aws_lib_client)
    )
  end

  describe '#initialize' do
    it 'sets the client' do
      client = described_class.new
      expect(client.instance_variable_get(:@client)).to eq aws_lib_client
    end
  end

  describe '#request' do
    subject(:client) { described_class.new }

    it 'is nil' do
      expect(client.request).to be_nil
    end

    context 'when @operation is set' do
      it 'delegates to operation' do
        request = double
        operation = instance_double(TranscriptionService::AWS::Client::BatchTranscription, request:)
        client.instance_variable_set(:@operation, operation)
        expect(client.request).to eq request
      end
    end
  end

  describe '#response' do
    subject(:client) { described_class.new }

    it 'is nil' do
      expect(client.response).to be_nil
    end

    context 'when @operation is set' do
      it 'delegates to operation' do
        response = double
        operation = instance_double(TranscriptionService::AWS::Client::BatchTranscription, response:)
        client.instance_variable_set(:@operation, operation)
        expect(client.response).to eq response
      end
    end
  end

  describe 'delegate missing' do
    before do
      allow(aws_lib_client).to receive(:start_transcription_job)
    end

    it 'delegates missing methods to the aws client' do
      described_class.new.start_transcription_job
      expect(aws_lib_client).to have_received(:start_transcription_job)
    end
  end

  describe '#batch_transcription' do
    subject(:client) { described_class.new }

    let(:blob) { build_stubbed :active_storage_blob }
    let(:options) { { a: 1 } }
    let(:batch_transcription) { instance_double(TranscriptionService::AWS::Client::BatchTranscription) }

    before do
      allow(TranscriptionService::AWS::Client::BatchTranscription).to receive(:call).and_return(batch_transcription)
    end

    it 'calls BatchTranscription with the proper args' do
      client.batch_transcribe(blob, **options)
      expect(TranscriptionService::AWS::Client::BatchTranscription).to(
        have_received(:call).with(client, blob, **options)
      )
    end

    it 'sets @operation' do
      client.batch_transcribe(blob, **options)
      expect(client.operation).to eq batch_transcription
    end

    context 'with a ConflictException' do
      it 're-raises' do
        allow(TranscriptionService::AWS::Client::BatchTranscription).to(
          receive(:call).and_raise(Aws::TranscribeService::Errors::ConflictException.new(nil, nil))
        )
        expect { client.batch_transcribe(blob, **options) }.to raise_error TranscriptionService::InvalidRequestError
      end
    end
  end

  describe '#get_batch_transcribe_job' do
    subject(:client) { described_class.new }

    let(:job_id) { 20 }
    let(:raw_response) { double }
    let(:response) { instance_double TranscriptionService::AWS::BatchTranscriptionResponse }

    before do
      allow(aws_lib_client).to receive(:get_transcription_job)
        .with(transcription_job_name: job_id).and_return(raw_response)
      allow(TranscriptionService::AWS::BatchTranscriptionResponse).to(
        receive(:new).with(raw_response).and_return(response)
      )
    end

    it 'returns a batch trascription response' do
      expect(client.get_batch_transcribe_job(job_id)).to eq response
    end
  end

  describe '#delete_batch_transcribe_job' do
    subject(:client) { described_class.new }

    let(:job_id) { 20 }

    before do
      allow(aws_lib_client).to receive(:delete_transcription_job)
    end

    it 'delegates to the aws lib client' do
      client.delete_batch_transcription_job(job_id)
      expect(aws_lib_client).to have_received(:delete_transcription_job).with(transcription_job_name: job_id)
    end

    context 'with a BadRequestException' do
      it 're-raises' do
        allow(aws_lib_client).to(
          receive(:delete_transcription_job)
            .and_raise(Aws::TranscribeService::Errors::BadRequestException.new(nil, nil))
        )
        expect { client.delete_batch_transcription_job(job_id) }.to(
          raise_error TranscriptionService::InvalidRequestError
        )
      end
    end
  end
end
