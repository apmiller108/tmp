class TranscribeJob
  include Sidekiq::Job

  def perform(blob_id, toxicity_detection: false)
    blob = ActiveStorage::Blob.find(blob_id)

    return unless blob.content_type =~ /\Aaudio/

    client = TranscriptionService::AwsClient.new(toxicity_detection:)
    response = TranscriptionService.batch_transcribe(client, blob)
    Rails.logger.info response.to_h
  end
end
