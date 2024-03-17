# frozen_string_literal: true

class AttachmentIconComponent < ApplicationViewComponent
  attr_reader :content_type, :filename

  # TODO: pass in blob id
  # TODO: use blob id to make turbo-frame id unique
  def initialize(content_type:, filename:)
    @content_type = content_type
    @filename = filename
  end

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
