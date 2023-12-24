require 'rails_helper'

describe TranscriptionService do
  subject(:service) { described_class.new(client) }

  let(:client) { instance_double(TranscriptionService::AWS::Client, batch_transcribe: nil, request:, response:) }
  let(:request) { instance_double(TranscriptionService::AWS::BatchTranscriptionRequest, params: { foo: :bar }) }
  let(:response) { instance_double(TranscriptionService::AWS:: BatchTranscriptionResponse, job_id: 'job-id', status: 'job-status') }
  let(:blob) { build_stubbed :active_storage_blob }

  describe '#request' do
    it 'delegates to the client' do
      expect(service.request).to eq request
    end
  end

  describe '#response' do
    it 'delegates to the client' do
      expect(service.response).to eq response
    end
  end

  describe '#job_id' do
    it 'delegates to the response' do
      expect(service.job_id).to eq response.job_id
    end
  end

  describe '#status' do
    it 'delegates to the response' do
      expect(service.status).to eq response.status
    end
  end

  describe '#params' do
    it 'delegates to the request' do
      expect(service.params).to eq request.params
    end
  end

  describe '#get_batch_transcribe_job' do
    it 'delegates to the client' do
      job_id = 'job id'
      response = double
      allow(client).to receive(:get_batch_transcribe_job).with(job_id).and_return(response)
      expect(service.get_batch_transcribe_job(job_id)).to eq response
    end
  end

  describe '#batch_transcribe' do
    let(:transcription_job) { build_stubbed :transcription_job }
    let(:options) { { a: 1 } }

    before do
      allow(TranscriptionJob).to receive(:create_for).with(transcription_service: service).and_return(transcription_job)
    end

    it 'delegates to the client' do
      service.batch_transcribe(blob, **options)
      expect(client).to have_received(:batch_transcribe).with(blob, **options)
    end

    it 'returns the transcription_job' do
      expect(service.batch_transcribe(blob, **options)).to eq transcription_job
    end
  end

  describe '.get_transcription' do
    subject(:get_transcription) { described_class.get_transcription(uri) }

    let(:uri) { 'http://example.com/transcriptions/1' }
    let(:transcript) { { id: 1 }.to_json }

    before do
      stub_request(:get, uri).to_return(status: 200, body: transcript)
    end

    it { is_expected.to eq JSON.parse transcript }
  end
end
