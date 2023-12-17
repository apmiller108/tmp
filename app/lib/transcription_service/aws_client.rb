require 'aws-sdk-transcribeservice'

class TranscriptionService
  class AwsClient
    def initialize(**options)
      @options = options
      @config = Rails.application.credentials.fetch(:aws)
    end

    def batch_transcribe(blob)
      @blob = blob
      client.start_transcription_job(transcription_job_params)
    end

    private

    attr_reader :config, :blob, :options

    def client
      @client = Aws::TranscribeService::Client.new(
        region: config[:region],
        credentials: Aws::Credentials.new(config.fetch(:access_key_id), config.fetch(:secret_access_key))
      )
    end

    def transcription_job_params
      {
        transcription_job_name:,
        language_code: 'en-US',
        media: {
          media_file_uri: resource_uri
        },
        tags:
      }.merge(additional_params)
    end

    def transcription_job_name
      "#{blob.id}_#{blob.filename}"
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
      "s3://#{config.fetch(:bucket)}/#{blob.key}"
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
            toxicity_categories: ['ALL'] # required, accepts ALL
          }
        ]
      }
    end

    def toxicity_detection? = options[:toxicity_detection].present?
  end
end
