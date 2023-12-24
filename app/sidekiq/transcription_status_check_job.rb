class TranscriptionStatusCheckJob
  include Sidekiq::Job

  def perform
    args = TranscriptionJob.unfinished.ids.map { |id| [id] }
    Sidekiq::Client.push_bulk('class' => TranscriptionRetrievalJob, 'args' => args)
  end
end
