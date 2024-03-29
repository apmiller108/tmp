module ActionTextRichTextExtension
  extend ActiveSupport::Concern

  included do
    # This supports doing active record joins to memo polymorphic
    # association (via record_id/record_type)
    # ex: `ActionText::RichText.joins(:memo))`

    # rubocop:disable Rails/InverseOf
    has_one :self_ref, class_name: 'ActionText::RichText', foreign_key: :id, dependent: nil
    has_one :memo, through: :self_ref, source: :record, source_type: 'Memo'
    # rubocop:enable Rails/InverseOf

    before_save { self.plain_text_body = body.to_plain_text }

    def plain_text_attachments
      return [] if plain_text_body.blank?

      plain_text_body.scan(ActiveStorage::Blob::PLAIN_TEXT_ATTACHMENT_PATTERN)
    end

    def blob_count_by_content_type
      embeds_blobs.group(:content_type).count
    end
  end
end
