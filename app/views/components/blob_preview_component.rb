# frozen_string_literal: true

class BlobPreviewComponent < ApplicationViewComponent
  attr_reader :blob, :resize_to_limit

  delegate :image?, :filename, to: :blob

  # @param [Boolean] contain. Keep the image contained to it's container (ie, prevent overflow)
  def initialize(blob:, resize_to_limit: [100, 100], contain: false)
    @blob = blob
    @resize_to_limit = resize_to_limit
    @contain = contain
  end

  def contain? = @contain

  def short_filename
    filename.to_s.truncate(25)
  end

  def variant_options
    {
      resize_to_limit:,
      **ActiveStorage::Blob::WEBP_VARIANT_OPTS
    }
  end
end
