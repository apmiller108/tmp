require 'rails_helper'

describe TranscriptionService do
  let(:client) { instance_double(TranscriptionService::AWS::Client, batch_transcribe: nil, request:, response:) }
  let(:request) { instance_double(TranscriptionService::AWS::BatchTranscriptionRequest, params: { foo: :bar }) }
  let(:response) { instance_double(TranscriptionService::AWS:: BatchTranscriptionResponse, job_id: 'job-id', status: 'job-status') }
  let(:blob) { build_stubbed :active_storage_blob }

  subject { described_class.new(client, blob) }

  describe '#request' do
    it 'delegates to the client' do
      expect(subject.request).to eq request
    end
  end

  describe '#response' do
    it 'delegates to the client' do
      expect(subject.response).to eq response
    end
  end

  describe '#job_id' do
    it 'delegates to the response' do
      expect(subject.job_id).to eq response.job_id
    end
  end

  describe '#status' do
    it 'delegates to the response' do
      expect(subject.status).to eq response.status
    end
  end

  describe '#params' do
    it 'delegates to the request' do
      expect(subject.params).to eq request.params
    end
  end

  describe '#batch_transcribe' do
    it 'delegates to the client' do
      subject.batch_transcribe
      expect(client).to have_received(:batch_transcribe).with(blob)
    end
  end
end
