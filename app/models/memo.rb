class Memo < ApplicationRecord
  SWATCHES = {
    swatch1: %w[03045e 0077b6 00b4d8 90e0ef caf0f8],
    swatch2: %w[03071E 6A040F D00000 E85D04 FAA307],
    swatch3: %w[1a4301 245501 538d22 73a942 aad576],
    swatch4: %w[0d1b2a 1b263b 415a77 778da9 e0e1dd],
    swatch5: %w[ef6351 f38375 f7a399 fbc3bc ffe3e0]
  }.freeze

  # Rich text:
  #  Associations:
  #    has_one :rich_text_content, class_name: 'ActionText::RichText'
  #  Attachments:
  #    content.embeds_attachments
  #  Blobs:
  #    content.embeds_blobs (this is through embeds_attachments)
  has_rich_text :content

  validates :content, :title, presence: true

  belongs_to :user, optional: false
  has_many :audio_blobs, -> { audio }, through: :rich_text_content, source: :embeds_blobs
  has_many :image_blobs, -> { image }, through: :rich_text_content, source: :embeds_blobs
  has_many :transcriptions, through: :audio_blobs
end
