class Memo < ApplicationRecord
  # Associations:
  #   has_one :rich_text_content, class_name: 'ActionText::RichText'
  # Attachments:
  #   content.embeds_attachments
  # Blobs:
  #   content.embeds_blobs (this is through embeds_attachments)
  has_rich_text :content

  validates :content, presence: true

  belongs_to :user, required: true, strict_loading: true
end
