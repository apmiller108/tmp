class TranscriptionService
  LANG = 'en-US'.freeze

  def self.batch_transcribe(client, blob)
    new(client, blob).batch_transcribe
  end

  attr_reader :client, :blob

  def initialize(client, blob)
    @client = client
    @blob = blob
  end

  def batch_transcribe
    client.batch_transcribe(blob)
  end
end
