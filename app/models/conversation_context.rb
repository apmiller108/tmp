class ConversationContext < ApplicationRecord
  belongs_to :user

  has_many :conversation_contexts_conversations, dependent: :destroy
  has_many :conversations, through: :conversation_contexts_conversations

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

  # @param user [User]
  # @param file_response [Anthropic::FileResponse]
  # @return [ConversationContext]
  def self.create_for!(user, file_response)
    create!(
      file_ref: file_response.id,
      filename: file_response.filename,
      mime_type: file_response.mime_type,
      context_type: context_types['file'],
      user_id: user.id
    )
  rescue StandardError
    raise CreateError
  end

  CreateError = Class.new(StandardError)
end
