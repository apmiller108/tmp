class Memo < ApplicationRecord
  # Associations:
  #   has_one :rich_text_content, class_name: 'ActionText::RichText'
  # Attachments:
  #   content.embeds_attachments
  # Blobs:
  #   content.embeds_blobs (this is through embeds_attachments)
  has_rich_text :content

  validates :content, presence: true

  belongs_to :user, optional: false
  has_many :audio_blobs, -> { audio }, through: :rich_text_content, source: :embeds_blobs
  has_many :transcriptions, through: :audio_blobs
end
