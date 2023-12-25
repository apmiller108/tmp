class TranscribableContentHandlerJob
  include Sidekiq::Job

  def perform(memo_id)
    blob_ids = ActiveStorage::Blob.not_transcribed_for(memo_id:).ids
    args = blob_ids.map { |id| [id] }
    Sidekiq::Client.push_bulk('class' => TranscribeAudioJob, 'args' => args)
  end
end
