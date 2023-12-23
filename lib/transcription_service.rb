class TranscriptionService
  LANG = 'en-US'.freeze
  InvalidRequestError = Class.new(StandardError)

  attr_reader :client

  delegate :blob, :get_batch_transcribe_job, :request, :response, to: :client
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
