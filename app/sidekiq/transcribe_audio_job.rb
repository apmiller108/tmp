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

    component = BlobComponent.new(blob:)
    user = User.find(blob.memo.user_id) # user cannot be lazily loaded
    ViewComponentBroadcaster.call([user, TurboStreams::STREAMS[:memos]], component:, action: :replace)
  rescue TranscriptionService::InvalidRequestError, ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
  end

  private

  def default_options
    {
      toxicity_detection: false
    }
  end

  def log_skipped(blob)
    Rails.logger.warn("#{self.class}: Skipped attempt to transcribe non-audio blob. "\
                      "id: #{blob.id}, content_type: #{blob.content_type}")
    nil
  end
end
