class ConversationContext < ApplicationRecord
  belongs_to :conversation

  validates :file_ref, :filename, presence: true

  after_destroy_commit -> { DeleteRemoteConversationContextJob.perform_async(file_ref) }

  enum :mime_type, {
    'text/csv' => 'text/csv',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel' => 'application/vnd.ms-excel',
    'application/json' => 'application/json',
    'application/xml' => 'application/xml',
    'application/pdf' => 'application/pdf',
    'text/xml' => 'text/xml',
    'image/jpeg' => 'image/jpeg',
    'image/png' => 'image/png',
    'image/gif' => 'image/gif',
    'image/webp' => 'image/webp',
    'text/plain' => 'text/plain',
    'text/markdown' => 'text/markdown',
    'text/x-python' => 'text/x-python'
  }, validate: true

  enum :context_type, {
    file: 'file'
  }, validate: true

  # @param conversation [Conversation]
  # @param file_response [Anthropic::FileResponse]
  # @return [ConversationContext]
  def self.create_for(conversation, file_response)
    conversation.contexts.create(
      file_ref: file_response.id,
      filename: file_response.filename,
      mime_type: file_response.mime_type,
      context_type: context_types['file']
    )
  end
end
