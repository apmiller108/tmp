class CleanupGoogleConversationContextsJob
  include Sidekiq::Job

  def perform
    ConversationContext.google.where('created_at < ?', 48.hours.ago).find_each do |context|
      context.destroy
    end
  end
end
