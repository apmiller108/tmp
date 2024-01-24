class TranscribeAudioJob
  include Sidekiq::Job

  sidekiq_options lock: :until_executed

  def perform(blob_id, opts = {})
    blob = ActiveStorage::Blob.find(blob_id)
    options = default_options.merge(opts.symbolize_keys)

    return log_skipped(blob) unless blob.audio?

    client = TranscriptionService::AWS::Client.new
    transcription_service = TranscriptionService.new(client)
    transcription_service.batch_transcribe(blob, **options)

    broadcast_blob(blob)
  rescue TranscriptionService::InvalidRequestError, ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
  end

  private

  def default_options
    {
      toxicity_detection: false
    }
  end

  def broadcast_blob(blob)
    component = BlobComponent.new(blob:)
    ViewComponentBroadcaster.call([blob.memo.user, TurboStreams::STREAMS[:memos]], component:, action: :replace)
  end

  def log_skipped(blob)
    Rails.logger.warn("#{self.class}: Skipped attempt to transcribe non-audio blob. "\
                      "id: #{blob.id}, content_type: #{blob.content_type}")
    nil
  end
end
