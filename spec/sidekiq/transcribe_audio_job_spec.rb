require 'rails_helper'

RSpec.describe TranscribeAudioJob, type: :job do
  let(:aws_client) { instance_double(TranscriptionService::AwsClient) }
  let(:blob_id) { 1 }
  let(:content_type) { 'audio/mp3' }
  let(:blob) { build_stubbed :active_storage_blob, id: blob_id, content_type: }
  let(:response) { { transciption_name: 'foo' } }

  before do
    allow(TranscriptionService::AwsClient).to receive(:new).and_return(aws_client)
    allow(TranscriptionService).to receive(:batch_transcribe).and_return(response)
    allow(ActiveStorage::Blob).to receive(:find).with(blob_id).and_return(blob)
  end

  it { expect(described_class).to have_valid_sidekiq_options }

  describe '#perform' do
    subject(:job) { described_class.new }

    it 'instantiates an AwsClient object' do
      job.perform(blob_id)
      expect(TranscriptionService::AwsClient).to have_received(:new).with(toxicity_detection: false)
    end

    it 'batch transcribes the blob' do
      job.perform(blob.id)
      expect(TranscriptionService).to have_received(:batch_transcribe).with(aws_client, blob)
    end

    context 'when the blob is not an audio file' do
      let(:content_type) { 'video/mp4' }

      it 'does not batch transcribes the blob' do
        job.perform(blob.id)
        expect(TranscriptionService).not_to have_received(:batch_transcribe)
      end

      it 'logs a warning' do
        expect(Rails.logger).to(
          receive(:warn).with(
            "TranscribeAudioJob: Skipped attempt to transcribe non-audio blob. id: #{blob.id}, content_type: #{content_type}"
          )
        )
        job.perform(blob.id)
      end
    end

    context 'when passing in the toxicity_detection argument' do
      it 'instantiates an AwsClient object with that option' do
        job.perform(blob_id, toxicity_detection: true)
        expect(TranscriptionService::AwsClient).to have_received(:new).with(toxicity_detection: true)
      end
    end
  end
end
