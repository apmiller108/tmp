class TranscriptionService
  LANG = 'en-US'.freeze

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
  end
end
