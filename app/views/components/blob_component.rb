# frozen_string_literal: true

class BlobComponent < ApplicationViewComponent
  DEFAULT_IMAGE_SIZE = [1024, 768].freeze
  GALLERY_IMAGE_SIZE = [800, 600].freeze

  attr_reader :blob, :in_gallery, :user

  delegate :audio?, :byte_size, :content_type, :filename, :representable?, :representation,
           :transcription_job, :url, to: :blob

  def initialize(blob:, in_gallery: true, user: current_user)
    @blob = blob
    @in_gallery = in_gallery
    @user = user
  end

  def id
    dom_id(blob)
  end

  def transcription_container_id
    "#{id}_transcription_container"
  end

  def caption
    return @caption if defined? @caption

    @caption = blob.try(:caption)
  end

  def caption? = caption.present?

  def humanized_file_size
    number_to_human_size byte_size
  end

  def resize_to_limit
    in_gallery ? GALLERY_IMAGE_SIZE : DEFAULT_IMAGE_SIZE
  end

  def fig_caption
    tag.figcaption(class: 'attachment__caption') do
      if caption?
        caption
      else
        tag.span(filename, class: 'attachment__name') +
          tag.span(humanized_file_size, class: 'attachment__size')
      end
    end
  end
end
