# frozen_string_literal: true

class AttachmentIconComponent < ApplicationViewComponent
  attr_reader :content_type, :blob_id

  def self.turbo_frame_id(blob_id)
    "blob_preview_#{blob_id}"
  end

  def initialize(blob_id:, content_type:)
    @blob_id = blob_id
    @content_type = content_type
  end

  def turbo_frame_id
    self.class.turbo_frame_id(blob_id)
  end

  def src
    blob_preview_path(blob_id)
  end

  private

  def attachment_icon_class
    case content_type
    when %r{\Aimage/}
      'bi bi-file-earmark-image'
    else
      'bi bi-file-earmark'
    end
  end
end
