require 'rails_helper'

RSpec.describe TranscriptionRetrievalJob, type: :job do
  subject(:job) { described_class.new }

  let(:transcription_job) do
    build_stubbed :transcription_job, status:, id: 100, active_storage_blob:
  end
  let(:memo) { build_stubbed :memo, :with_user }
  let(:active_storage_blob) { build_stubbed :active_storage_blob }
  let(:transcription_job_results) { double }
  let(:remote_job) do
    instance_double(TranscriptionService::AWS::BatchTranscriptionResponse,
                    failure_reason:, transcript_file_uri:, finished?: finished?, status: remote_status)
  end
  let(:finished?) { true }
  let(:transcript_file_uri) { 'http://example.com/job1' }
  let(:transcript_response) { JSON.parse file_fixture('transcription/response_diarized.json').read }
  let(:failure_reason) { nil }
  let(:status) { TranscriptionJob.statuses[:in_progress] }
  let(:remote_status) { TranscriptionJob.statuses[:completed] }
  let(:blob_component) { instance_double(BlobComponent) }

  it { expect(described_class).to have_valid_sidekiq_options }

  describe '#perform' do
    before do
      allow(TranscriptionJob).to receive(:find).with(transcription_job.id).and_return(transcription_job)
      allow(transcription_job).to receive(:update!)
      allow(transcription_job).to receive(:results).and_return(transcription_job_results)
      allow(transcription_job).to receive(:remote_job).and_return(remote_job)
      allow(TranscriptionService).to receive(:get_transcription).with(transcript_file_uri).and_return(transcript_response)
      allow(Transcription).to receive(:create!)
      allow(Rails.logger).to receive(:warn)
      allow(BlobComponent).to receive(:new).with(blob: active_storage_blob).and_return(blob_component)
      allow(ViewComponentBroadcaster).to receive(:call)
      allow(active_storage_blob).to receive(:memo).and_return(memo)
      allow(User).to receive(:find).with(memo.user_id).and_return(memo.user)
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

      it 'does not broadcast the blob component' do
        job.perform(transcription_job.id)
        expect(ViewComponentBroadcaster).not_to have_received(:call)
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

      it 'broadcasts the blob component' do
        job.perform(transcription_job.id)
        expect(ViewComponentBroadcaster).to(
          have_received(:call)
            .with([memo.user, TurboStreams::STREAMS[:blobs]], component: blob_component, action: :replace)
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

      it 'broadcasts the blob component' do
        job.perform(transcription_job.id)
        expect(ViewComponentBroadcaster).to(
          have_received(:call)
            .with([memo.user, TurboStreams::STREAMS[:blobs]], component: blob_component, action: :replace)
        )
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

      it 'does not broadcast the blob component' do
        job.perform(transcription_job.id)
        expect(ViewComponentBroadcaster).not_to have_received(:call)
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
