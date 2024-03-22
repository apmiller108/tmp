# frozen_string_literal: true

class BlobPreviewComponent < ApplicationViewComponent
  attr_reader :blob

  delegate :image?, to: :blob

  def initialize(blob:)
    @blob = blob
  end

  def filename
    blob.filename.to_s[0, 15]
  end

  def variant_options
    {
      resize_to_limit: [100, 100],
      **ActiveStorage::Blob::WEBP_VARIANT_OPTS
    }
  end
end
