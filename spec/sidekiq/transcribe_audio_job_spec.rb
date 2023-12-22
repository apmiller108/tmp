require 'rails_helper'

RSpec.describe TranscribeAudioJob, type: :job do
  let(:aws_client) { instance_double(TranscriptionService::AWS::Client) }
  let(:transcription_service) { instance_double(TranscriptionService, batch_transcribe: nil) }
  let(:transcription_job) { build_stubbed :transcription_job }
  let(:blob_id) { 1 }
  let(:content_type) { 'audio/mp3' }
  let(:blob) { build_stubbed :active_storage_blob, id: blob_id, content_type: }
  let(:response) { { transciption_name: 'foo' } }

  before do
    allow(TranscriptionService::AWS::Client).to receive(:new).and_return(aws_client)
    allow(TranscriptionService).to receive(:new).with(aws_client, blob).and_return(transcription_service)
    allow(ActiveStorage::Blob).to receive(:find).with(blob_id).and_return(blob)
    allow(transcription_service).to receive(:batch_transcribe).and_return(transcription_job)
  end

  it { expect(described_class).to have_valid_sidekiq_options }

  describe '#perform' do
    subject(:job) { described_class.new }

    it 'instantiates an AWS::Client object' do
      job.perform(blob_id)
      expect(TranscriptionService::AWS::Client).to have_received(:new).with(toxicity_detection: false)
    end

    it 'batch transcribes the blob' do
      job.perform(blob.id)
      expect(transcription_service).to have_received(:batch_transcribe)
    end

    it 'returns the transcription_job' do
      expect(job.perform(blob.id)).to eq transcription_job
    end

    context 'when the blob is not an audio file' do
      let(:content_type) { 'video/mp4' }

      it 'does not batch transcribes the blob' do
        job.perform(blob.id)
        expect(transcription_service).not_to have_received(:batch_transcribe)
      end

      it 'logs a warning' do
        expect(Rails.logger).to receive(:warn).with('TranscribeAudioJob: Skipped attempt to '\
                                                    "transcribe non-audio blob. id: #{blob.id}, "\
                                                    "content_type: #{content_type}")
        job.perform(blob.id)
      end

      it 'returns nil' do
        expect(job.perform(blob.id)).to be_nil
      end
    end

    context 'when passing in the toxicity_detection argument' do
      it 'instantiates an AWS::Client object with that option' do
        job.perform(blob_id, toxicity_detection: true)
        expect(TranscriptionService::AWS::Client).to have_received(:new).with(toxicity_detection: true)
      end
    end

    context 'with a TranscribeService::InvalidRequestError' do
      before do
        allow(transcription_service).to receive(:batch_transcribe).and_raise(TranscriptionService::InvalidRequestError)
        allow(Rails.logger).to receive(:warn)
      end

      it 'resuces and logs the error' do
        job.perform(blob_id)
        expect(Rails.logger).to have_received(:warn).with('TranscribeAudioJob: TranscriptionService::InvalidRequestError : ')
      end

      it 'returns nil' do
        expect(job.perform(blob.id)).to be_nil
      end
    end

    context 'when the blob cannot be found' do
      before do
        allow(ActiveStorage::Blob).to receive(:find).with(blob_id).and_raise ActiveRecord::RecordNotFound
        allow(Rails.logger).to receive(:warn)
      end

      it 'rescues and logs the error' do
        job.perform(blob_id)
        expect(Rails.logger).to have_received(:warn).with('TranscribeAudioJob: ActiveRecord::RecordNotFound : ')
      end

      it 'returns nil' do
        expect(job.perform(blob.id)).to be_nil
      end
    end
  end
end
