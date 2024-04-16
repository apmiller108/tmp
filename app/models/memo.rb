class Memo < ApplicationRecord
  SWATCHES = {
    swatch1: %w[03045e 0077b6 00b4d8 90e0ef caf0f8],
    swatch2: %w[036666 248277 469d89 67b99a 88d4ab],
    swatch3: %w[590d22 a4133c ff4d6d ff8fa3 ffccd5],
    swatch4: %w[ff4800 ff6000 ff7900 ff9100 ffaa00],
    swatch5: %w[0d1b2a 1b263b 415a77 778da9 e0e1dd]
  }.freeze

  COLORS = SWATCHES.inject([ColorType::DEFAULT]) do |colors, (_, hex_values)|
    colors + hex_values
  end.freeze

  # Rich text:
  #  Associations:
  #    has_one :rich_text_content, class_name: 'ActionText::RichText'
  #  Attachments:
  #    content.embeds_attachments
  #  Blobs:
  #    content.embeds_blobs (this is through embeds_attachments)
  has_rich_text :content

  validates :title, presence: true
  validate :color_inclusion

  belongs_to :user, optional: false
  has_many :audio_blobs, -> { audio }, through: :rich_text_content, source: :embeds_blobs
  has_many :image_blobs, -> { image }, through: :rich_text_content, source: :embeds_blobs
  has_many :transcriptions, through: :audio_blobs

  delegate :plain_text_body, :plain_text_attachments, :body_previously_changed?, to: :content

  after_save_commit do
    ComputeStatsJob.perform_async(id) if body_previously_changed?
  end

  def color
    ColorType.new(super)
  end

  def default_color?
    color.default?
  end

  def content_attachment_counts
    @content_attachment_counts ||= content.blob_count_by_content_type
  end

  private

  def color_inclusion
    return if color.hex_color.in?(COLORS)

    errors.add(:color, 'is not included in the list')
  end
end
