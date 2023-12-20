# TODO: rename this TranscribeAudioJob ?
class TranscribeJob
  include Sidekiq::Job

  def perform(blob_id, toxicity_detection: false)
    blob = ActiveStorage::Blob.find(blob_id)

    # TODO: raise rescue and log this. Do not retry
    return unless blob.content_type =~ /\Aaudio/

    client = TranscriptionService::AwsClient.new(toxicity_detection:)
    # TODO: handle job already created error. Rescue and do not retry
    response = TranscriptionService.batch_transcribe(client, blob)
    Rails.logger.info response.to_h
  end
end
