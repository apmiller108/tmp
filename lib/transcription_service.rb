class TranscriptionService
  LANG = 'en-US'.freeze
  InvalidRequestError = Class.new(StandardError)

  attr_reader :client

  delegate :blob, :get_batch_transcribe_job, :delete_batch_transcription_job,
           :request, :response, to: :client
  delegate :job_id, :status, to: :response
  delegate :params, to: :request

  def self.get_transcription(uri)
    conn = Faraday.new { |f| f.response :raise_error }
    JSON.parse(conn.get(uri).body)
  end

  def initialize(client = AWS::Client.new)
    @client = client
  end

  def batch_transcribe(blob, **options)
    client.batch_transcribe(blob, **options)
    TranscriptionJob.create_for(transcription_service: self)
  end
end
