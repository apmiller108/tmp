# frozen_string_literal: true

class AttachmentIconComponent < ApplicationViewComponent
  attr_reader :content_type, :filename, :blob_id

  def self.turbo_frame_id(blob_id)
    "blob_preview_#{blob_id}"
  end

  def initialize(blob_id:, content_type:, filename:)
    @blob_id = blob_id
    @content_type = content_type
    @filename = filename
  end

  def turbo_frame_id
    self.class.turbo_frame_id(blob_id)
  end

  def src
    blob_preview_path(blob_id)
  end

  private

  # rubocop:disable Metrics/MethodLength
  def attachment_icon_class
    case content_type
    when /jpe?g/
      'bi bi-filetype-jpg'
    when /mp3/
      'bi bi-filetype-mp3'
    when /png/
      'bi bi-filetype-png'
    when /wav/
      'bi bi-filetype-wav'
    else
      'bi bi-file-earmark'
    end
  end
  # rubocop:enable Metrics/MethodLength
end
