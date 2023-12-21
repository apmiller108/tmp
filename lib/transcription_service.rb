class TranscriptionService
  LANG = 'en-US'.freeze

  def self.batch_transcribe(client, blob)
    service = new(client, blob)
    service.batch_transcribe
    service
  end

  attr_reader :client, :blob

  delegate :request, :response, to: :client

  def initialize(client, blob)
    @client = client
    @blob = blob
  end

  def batch_transcribe
    client.batch_transcribe(blob)
  end
end
