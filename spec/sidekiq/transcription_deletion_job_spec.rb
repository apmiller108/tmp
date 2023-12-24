require 'rails_helper'
RSpec.describe TranscriptionDeletionJob, type: :job do
  subject(:job) { described_class.new }

  let(:remote_job_id) { double }
  let(:transcription_service) { instance_double TranscriptionService }

  before do
    allow(TranscriptionService).to receive(:new).and_return transcription_service
    allow(transcription_service).to receive(:delete_batch_transcription_job)
    allow(Rails.logger).to receive(:warn)
  end

  describe '#perform' do
    it 'deletes the job' do
      job.perform(remote_job_id)
      expect(transcription_service).to have_received(:delete_batch_transcription_job).with(remote_job_id)
    end

    context 'with an InvalidRequestError' do
      before do
        allow(transcription_service).to(
          receive(:delete_batch_transcription_job).and_raise(TranscriptionService::InvalidRequestError)
        )
      end
      it 'resuces and logs the error' do
        job.perform(remote_job_id)
        expect(Rails.logger).to(
          have_received(:warn).with('TranscriptionDeletionJob: TranscriptionService::InvalidRequestError '\
                                     ": remote_job_id: #{remote_job_id}")
        )
      end
    end
  end
end
