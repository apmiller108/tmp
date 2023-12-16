# frozen_string_literal: true

class BlobComponent < ApplicationViewComponent
  attr_reader :blob, :in_gallery

  delegate :audio?, :byte_size, :content_type, :filename, :representable?, :representation, :url, to: :blob

  def initialize(blob:, in_gallery:)
    @blob = blob
    @in_gallery = in_gallery
  end

  def caption
    return @caption if defined? @caption

    @caption = blob.try(:caption)
  end

  def caption? = caption.present?
end
