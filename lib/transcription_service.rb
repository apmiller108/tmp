class TranscriptionService
  LANG = 'en-US'.freeze
  InvalidRequestError = Class.new(StandardError)

  attr_reader :client, :blob

  delegate :request, :response, to: :client
  delegate :job_id, :status, to: :response
  delegate :params, to: :request

  def initialize(client, blob)
    @client = client
    @blob = blob
  end

  def batch_transcribe
    client.batch_transcribe(blob)
    TranscriptionJob.create_for(transcription_service: self)
  end
end
