require 'aws-sdk-transcribeservice'

class TranscriptionService
  class AwsClient
    def initialize(**options)
      @options = options
      @config = Rails.application.credentials.fetch(:aws)
    end

    def batch_transcribe(blob)
      client.start_transcription_job(AwsTranscriptionJobParams.for(blob:, **options))
    end

    private

    attr_reader :config, :blob, :options

    def client
      @client = Aws::TranscribeService::Client.new(
        region: config[:region],
        credentials: Aws::Credentials.new(config.fetch(:access_key_id), config.fetch(:secret_access_key))
      )
    end
  end
end
