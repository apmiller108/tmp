class DeleteRemoteConversationContextJob
  include Sidekiq::Job

  def perform(file_id, vendor)
    case vendor.to_sym
    when :anthropic
      Anthropic.delete_file(file_id)
    when :google
      Gemini.delete_file(file_id)
    else
      Rails.logger.warn("#{self.class}: Unknown vendor #{vendor}")
    end
  rescue StandardError => e
    Rails.logger.error("#{self.class}: Failed to delete remote file #{file_id} for vendor #{vendor}: #{e.message}")
  end
end
