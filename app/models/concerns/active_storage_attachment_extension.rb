module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    # This supports doing active record joins to rich_text_content polymorphic
    # association (via record_id/record_type)
    # ex: `ActiveStorage::Attachments.joins(:rich_text))`
    has_one :self_ref, class_name: 'ActiveStorage::Attachment', foreign_key: :id
    has_one :rich_text, through: :self_ref, source: :record, source_type: 'ActionText::RichText'
  end
end
