class TranscribeAudioJob
  include Sidekiq::Job

  sidekiq_options lock: :until_executed

  def perform(blob_id, toxicity_detection: false)
    # TODO: rescue ActiveRecord::NotFound, log and don't retry
    # TODO: handle job already created error. Rescue and do not retry
    blob = ActiveStorage::Blob.find(blob_id)

    return log_skipped(blob) unless blob.audio?

    client = TranscriptionService::AwsClient.new(toxicity_detection:)
    transcription_service = TranscriptionService.new(client, blob)
    transcription_service.batch_transcribe
    TranscriptionJob.create(request: transcription_service.request, response: transcription_service.response)
  end

  private

  def log_skipped(blob)
    Rails.logger.warn("#{self.class}: Skipped attempt to transcribe non-audio blob. id: #{blob.id}, content_type: #{blob.content_type}")
  end
end
