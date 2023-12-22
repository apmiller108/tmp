class TranscriptionService
  module AWS
    class BatchTranscriptionRequest
      JOB_NAME_MAX_LENGTH = 200

      def initialize(blob, **options)
        @blob = blob
        @options = options
      end

      def params
        {
          transcription_job_name:,
          language_code: TranscriptionService::LANG,
          media: {
            media_file_uri: resource_uri
          },
          tags:
        }.merge(additional_params)
      end

      private

      attr_reader :blob, :options

      def transcription_job_name
        "#{blob.id}_#{blob.filename}".slice(0, JOB_NAME_MAX_LENGTH)
      end

      def tags
        [
          {
            key: 'blob_id',
            value: blob.id.to_s
          }
        ]
      end

      def resource_uri
        "s3://#{Rails.application.credentials.dig(:aws, :bucket)}/#{blob.key}"
      end

      # AWS does not support toxicity with diarization
      def additional_params
        if toxicity_detection?
          toxicity_settings
        else
          diarization_settings
        end
      end

      def diarization_settings
        {
          settings: {
            show_speaker_labels: true,
            max_speaker_labels: 2,
            channel_identification: false,
            show_alternatives: false
          }
        }
      end

      def toxicity_settings
        {
          toxicity_detection: [
            {
              toxicity_categories: ['ALL']
            }
          ]
        }
      end

      def toxicity_detection? = options[:toxicity_detection].present?
    end
  end
end
