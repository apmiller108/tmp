# frozen_string_literal: true

class BlobPreviewComponent < ApplicationViewComponent
  attr_reader :blob

  delegate :image?, :filename, to: :blob

  def initialize(blob:)
    @blob = blob
  end

  def short_filename
    filename.to_s.truncate(25)
  end

  def variant_options
    {
      resize_to_limit: [100, 100],
      **ActiveStorage::Blob::WEBP_VARIANT_OPTS
    }
  end
end
