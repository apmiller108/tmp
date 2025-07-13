class DeleteRemoteConversationContextJob
  include Sidekiq::Job

  def perform(file_id)
    Anthropic.delete_file(file_id)
  end
end
