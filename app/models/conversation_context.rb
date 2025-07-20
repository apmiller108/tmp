class ConversationContext < ApplicationRecord
  belongs_to :user

  has_many :conversation_contexts_conversations, dependent: :destroy
  has_many :conversations, through: :conversation_contexts_conversations

  validates :file_ref, :filename, presence: true

  after_destroy_commit -> { DeleteRemoteConversationContextJob.perform_async(file_ref) }

  # rubocop:disable Layout/LineLength
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
  # rubocop:enable Layout/LineLength

  enum :context_type, {
    file: 'file'
  }, validate: true

  DOCUMENT_CONTENT_TYPE = 'document'.freeze
  IMAGE_CONTENT_TYPE = 'image'.freeze
  DEFAULT_CONTENT_BLOCK_TYPE = 'container_upload'.freeze
  CONTENT_BLOCK_TYPES = {
    ['application/pdf', 'text/plain'] => DOCUMENT_CONTENT_TYPE,
    ['image/jpeg', 'image/png', 'image/gif', 'image/webp'] => IMAGE_CONTENT_TYPE
  }.freeze

  CreateError = Class.new(StandardError)

  scope :available_for, ->(conversation) {
    where('id NOT IN (:ids)',
          ids: ConversationContext.select(:id)
                                  .joins(conversation_contexts_conversations: :conversation)
                                  .where(conversation: { id: conversation.id }))
  }

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

  def to_content_block
    {
      type: content_block_type,
      source: {
        type: context_type,
        file_id: file_ref
      },
      **metadata
    }
  end

  # @return [String] the type of content block to use when including this context in a conversation
  def content_block_type
    CONTENT_BLOCK_TYPES.find { |types, _| types.include?(mime_type) }&.last || DEFAULT_CONTENT_BLOCK_TYPE
  end

  def metadata
    if content_block_type == DOCUMENT_CONTENT_TYPE
      { filename: }
    else
      {}
    end
  end
end
