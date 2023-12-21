require 'aws-sdk-transcribeservice'

class TranscriptionService
  class AwsClient
    attr_reader :response

    def initialize(**options)
      @options = options
      @config = Rails.application.credentials.fetch(:aws)
    end

    def batch_transcribe(blob)
      @blob = blob
      @response = client.start_transcription_job(@batch_transcribe_params)
    end

    def params
      AwsTranscriptionJobParams.for(blob:, **options)
    end
    alias request params

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
