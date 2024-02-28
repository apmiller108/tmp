module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  included do |base|
    base.const_set(:PLAIN_TEXT_ATTACHMENT_TEMPLATE, '%%JSON{{%<json>s}}')
    base.const_set(:PLAIN_TEXT_ATTACHMENT_PATTERN, /%JSON\{\{.+\}\}/)
    base.const_set(:PLAIN_TEXT_JSON_ATTACHMENT_PATTERN, /%JSON\{\{(?<json>.+)\}\}/)

    has_one :transcription_job, foreign_key: :active_storage_blob_id,
                                inverse_of: :active_storage_blob, dependent: :destroy
    has_one :transcription, foreign_key: :active_storage_blob_id,
                            inverse_of: :active_storage_blob, dependent: :destroy
    has_one :generaete_image_request, dependent: :destroy

    # rubocop:disable Rails/InverseOf
    has_one :rich_text_attachment, -> {
      where(name: 'embeds', record_type: 'ActionText::RichText')
    }, class_name: 'ActiveStorage::Attachment', dependent: nil
    # rubocop:enable Rails/InverseOf
    has_one :rich_text, through: :rich_text_attachment
    has_one :memo, through: :rich_text

    scope :audio, -> { where("content_type like 'audio/%'") }
    scope :image, -> { where("content_type like 'image/%'") }
    scope :audio_not_transcribed_for, ->(memo_id:) {
      audio
        .joins(attachments: { rich_text: :memo })
        .left_joins(:transcription)
        .where(memos: { id: memo_id }, transcriptions: { id: nil })
    }

    def attachable_plain_text_representation(caption = nil)
      # rubocop:disable Style/FormatString
      caption || sprintf(self.class::PLAIN_TEXT_ATTACHMENT_TEMPLATE,
                         json: attributes.slice('content_type', 'filename').to_json)
      # rubocop:enable Style/FormatString
    end
  end
end
