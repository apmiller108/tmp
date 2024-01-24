module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  included do
    has_one :transcription_job, foreign_key: :active_storage_blob_id, inverse_of: :active_storage_blob,
                                dependent: :destroy
    has_one :transcription, foreign_key: :active_storage_blob_id, inverse_of: :active_storage_blob, dependent: :destroy
    has_one :rich_text_attachment, -> {
      where(name: 'embeds', record_type: 'ActionText::RichText')
    }, class_name: 'ActiveStorage::Attachment'
    has_one :rich_text, through: :rich_text_attachment
    has_one :memo, through: :rich_text

    scope :audio, -> { where("content_type like 'audio/%'") }
    scope :image, -> { where("content_type like 'image/%'") }
    scope :not_transcribed_for, ->(memo_id:) {
      audio
        .joins(attachments: { rich_text: :memo })
        .left_joins(:transcription)
        .where(memos: { id: memo_id }, transcriptions: { id: nil })
    }
  end
end
