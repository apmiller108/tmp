require 'rails_helper'

RSpec.describe TranscriptionService::AWS::BatchTranscriptionRequest do
  describe '#params' do
    subject(:params) { described_class.new(blob, **options).params }

    let(:blob) { build_stubbed :active_storage_blob }
    let(:options) { {} }

    let(:expected_params) do
      { transcription_job_name: "#{blob.id}_#{blob.filename}",
        language_code: TranscriptionService::LANG,
        media: { media_file_uri: "s3://#{Rails.application.credentials.dig(:aws, :bucket)}/#{blob.key}" },
        tags: [{ key: 'blob_id', value: blob.id.to_s }],
        settings: { show_speaker_labels: true, max_speaker_labels: 2, channel_identification: false,
                    show_alternatives: false } }
    end

    it { is_expected.to eq expected_params }

    context 'with the toxicity_detection option' do
      let(:expected_params) do
        { transcription_job_name: "#{blob.id}_#{blob.filename}",
          language_code: TranscriptionService::LANG,
          media: { media_file_uri: "s3://#{Rails.application.credentials.dig(:aws, :bucket)}/#{blob.key}" },
          tags: [{ key: 'blob_id', value: blob.id.to_s }],
          toxicity_detection: [{ toxicity_categories: ['ALL'] }] }
      end
      let(:options) { { toxicity_detection: true } }

      it { is_expected.to eq expected_params }
    end

    context 'when the computed job name exceeds 200 charcters' do
      let(:blob) { build_stubbed :active_storage_blob, filename: Faker::Alphanumeric.alphanumeric(number: 201) }

      it 'truncates the job name' do
        expect(params[:transcription_job_name].length).to eq 200
      end
    end
  end
end
