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

  def humanized_file_size
    number_to_human_size byte_size
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
