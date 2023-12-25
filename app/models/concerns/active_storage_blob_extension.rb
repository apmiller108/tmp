module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  included do
    has_one :transcription_job, foreign_key: :active_storage_blob_id, dependent: :destroy
    has_one :transcription, foreign_key: :active_storage_blob_id, dependent: :destroy

    scope :audio, -> { where("content_type like 'audio/%'") }
    scope :not_transcribed_for, ->(memo_id:) {
      audio
        .joins(attachments: { rich_text_content: :memo })
        .left_joins(:transcription)
        .where(memos: { id: memo_id }, transcriptions: { id: nil })
    }
  end
end
