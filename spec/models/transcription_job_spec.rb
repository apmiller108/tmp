require 'rails_helper'

RSpec.describe TranscriptionJob, type: :model do
  it 'declares status enum' do
    expect(described_class.statuses).to eq({
      'created' => 'created', 'queued' => 'queued', 'in_progress' => 'in_progress',
      'failed' => 'failed', 'completed' => 'completed'
    })
  end

  describe 'callbacks' do
    describe 'after_destroy_commit' do
      before do
        allow(TranscriptionDeletionJob).to receive(:perform_async)
      end

      let(:transcription_job) { create :transcription_job, remote_job_id: '20_resdogs.wav' }

      it 'enqueues a job to delete the remote job' do
        transcription_job.destroy
        expect(TranscriptionDeletionJob).to have_received(:perform_async).with(transcription_job.remote_job_id)
      end
    end
  end

  describe '.create_for' do
    let(:params) { { transcription_job_name: 'job-name' } }
    let(:job_id) { 'job-id' }
    let(:status) { 'in_progress' }
    let(:active_storage_blob) { create :active_storage_blob }
    let(:transcription_service) do
      instance_double(TranscriptionService, status:, params:, job_id:, blob: active_storage_blob)
    end

    it 'creates a new record with the request params and job id' do
      transcription_job = described_class.create_for(transcription_service:)
      expect(transcription_job.attributes).to(
        include 'remote_job_id' => job_id,
                'active_storage_blob_id' => active_storage_blob.id,
                'request' => params.stringify_keys,
                'status' => status,
                'response' => nil
      )
    end
  end

  describe '#results' do
    subject(:results) { described_class.new(response:).results }

    let(:response) { JSON.parse(file_fixture('transcription/response_toxicity.json').read) }

    it 'returns the transcript' do
      expect(results).to eq response['results']['transcripts'][0]['transcript']
    end

    context 'when there is no response' do
      subject(:job) { described_class.new.results }

      it { is_expected.to eq({}) }
    end
  end

  describe '#remote_job' do
    subject(:job) { described_class.new }

    let(:client) { instance_double(TranscriptionService::AWS::Client) }
    let(:transcription_service) { instance_double(TranscriptionService) }
    let(:remote_job) { instance_double TranscriptionService::AWS::BatchTranscriptionResponse }

    before do
      allow(TranscriptionService::AWS::Client).to receive(:new).and_return(client)
      allow(TranscriptionService).to receive(:new).with(client).and_return(transcription_service)
      allow(transcription_service).to receive(:get_batch_transcribe_job).and_return(remote_job)
    end

    it 'returns the remote job' do
      expect(job.remote_job).to equal remote_job
    end
  end
end
