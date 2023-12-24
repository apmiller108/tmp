require 'rails_helper'

RSpec.describe TranscriptionRetrievalJob, type: :job do
  subject(:job) { described_class.new }

  let(:transcription_job) do
    build_stubbed :transcription_job, status:, remote_job_id:, id: 100, active_storage_blob_id: 101
  end
  let(:transcription_job_results) { double }
  let(:transcription_service) { instance_double(TranscriptionService) }
  let(:remote_job) do
    instance_double(TranscriptionService::AWS::BatchTranscriptionResponse,
                    failure_reason:, transcript_file_uri:, finished?: finished?, status: remote_status)
  end
  let(:finished?) { true }
  let(:remote_job_id) { 'remote job id' }
  let(:transcript_file_uri) { 'http://example.com/job1' }
  let(:transcript_response) { JSON.parse file_fixture('transcription/response_diarized.json').read }
  let(:failure_reason) { nil }
  let(:client) { instance_double(TranscriptionService::AWS::Client) }
  let(:status) { TranscriptionJob.statuses[:in_progress] }
  let(:remote_status) { TranscriptionJob.statuses[:completed] }

  it { expect(described_class).to have_valid_sidekiq_options }

  describe '#perform' do
    before do
      allow(TranscriptionService::AWS::Client).to receive(:new).and_return(client)
      allow(TranscriptionService).to receive(:new).with(client).and_return(transcription_service)
      allow(TranscriptionJob).to receive(:find).with(transcription_job.id).and_return(transcription_job)
      allow(transcription_service).to receive(:get_batch_transcribe_job).with(remote_job_id).and_return(remote_job)
      allow(transcription_job).to receive(:update!)
      allow(transcription_job).to receive(:results).and_return(transcription_job_results)
      allow(TranscriptionService).to receive(:get_transcription).with(transcript_file_uri).and_return(transcript_response)
      allow(Transcription).to receive(:create!)
      allow(Rails.logger).to receive(:warn)
    end

    context 'when the transcription already exists' do
      let(:transcription_job) { build_stubbed :transcription_job, :with_transcription }

      it 'does not update the transcription_job' do
        job.perform(transcription_job.id)
        expect(transcription_job).not_to have_received(:update!)
      end

      it 'does not create the transcription' do
        job.perform(transcription_job.id)
        expect(Transcription).not_to have_received(:create!)
      end

      it 'logs a warning' do
        job.perform(transcription_job.id)
        expect(Rails.logger).to have_received(:warn)
          .with('TranscriptionRetrievalJob: skipped job : transcription already exists')
      end
    end

    context 'when the remote job is completed' do
      before do
        allow(remote_job).to receive(:completed?).and_return(true)
      end

      it 'updates the transcription_job with the transcript response and status' do
        job.perform(transcription_job.id)
        expect(transcription_job).to have_received(:update!)
          .with(response: transcript_response, status: remote_status)
      end

      it 'creates the transcription' do
        job.perform(transcription_job.id)
        expect(Transcription).to(
          have_received(:create!).with(
            transcription_job:,
            content: transcription_job_results,
            active_storage_blob_id: transcription_job.active_storage_blob_id
          )
        )
      end
    end

    context 'when the remote job failed' do
      let(:remote_status) { TranscriptionJob.statuses[:failed] }
      let(:failure_reason) { 'failure reason' }

      before do
        allow(remote_job).to receive(:completed?).and_return(false)
        allow(remote_job).to receive(:failed?).and_return(true)
      end

      it 'updates the transcription_job with the failure reason and status' do
        job.perform(transcription_job.id)
        expect(transcription_job).to have_received(:update!)
          .with(response: { failure_reason: }, status: remote_status)
      end

      it 'does not create the transcription' do
        job.perform(transcription_job.id)
        expect(Transcription).not_to have_received(:create!)
      end
    end

    context 'when the remote job is not finished' do
      let(:finished?) { false }

      it 'does not update the transcription_job' do
        job.perform(transcription_job.id)
        expect(transcription_job).not_to have_received(:update!)
      end

      it 'does not create the transcription' do
        job.perform(transcription_job.id)
        expect(Transcription).not_to have_received(:create!)
      end

      it 'logs a warning' do
        job.perform(transcription_job.id)
        expect(Rails.logger).to have_received(:warn)
          .with('TranscriptionRetrievalJob: skipped job : remote transcription job not finished')
      end
    end

    context 'when the transcription_job does not exist' do
      before do
        allow(TranscriptionJob).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        allow(Rails.logger).to receive(:warn)
      end

      it 'rescues the error and logs' do
        job.perform(transcription_job.id)
        expect(Rails.logger).to have_received(:warn)
          .with('TranscriptionRetrievalJob: ActiveRecord::RecordNotFound : '\
                "transcription_job_id: #{transcription_job.id}")
      end
    end
  end
end
