class TranscriptionService
  LANG = 'en-US'.freeze
  InvalidRequestError = Class.new(StandardError)

  attr_reader :client

  delegate :request, :response, :blob, to: :client
  delegate :job_id, :status, to: :response
  delegate :params, to: :request

  def initialize(client)
    @client = client
  end

  def batch_transcribe(blob, **options)
    client.batch_transcribe(blob, **options)
    TranscriptionJob.create_for(transcription_service: self)
  end
end
