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
end
