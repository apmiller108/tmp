# frozen_string_literal: true

class MemoCardComponent < ApplicationViewComponent
  with_collection_parameter :memo

  attr_reader :memo

  delegate :color, :title, :plain_text_attachments, :image_attachment_count, :audio_attachment_count,
           :video_attachment_count, :attachment_count, to: :memo

  def initialize(memo:)
    @memo = memo
  end

  def id
    "card_#{dom_id(memo)}"
  end

  def plain_text_body
    memo.plain_text_body || ''
  end

  def plain_text_body_with_attachment_icons
    return @plain_text_body_with_attachment_icons if defined? @plain_text_body_with_attachment_icons

    @plain_text_body_with_attachment_icons = begin
      plain_text_attachments.each_with_object(plain_text_body.dup) do |tag, text|
        data = JSON.parse(tag.match(ActiveStorage::Blob::PLAIN_TEXT_JSON_ATTACHMENT_PATTERN)[:json])
        text.sub!(tag, attachment_icon(data))
      end
    rescue StandardError => e
      Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
      plain_text_body
    end
  end

  def preview_text
    sanitize_preview(plain_text_body_with_attachment_icons)
  end

  def created_at
    time_ago_in_words(memo.created_at)
  end

  def updated_at
    time_ago_in_words(memo.updated_at)
  end

  def background_style
    "background-color: rgba(#{color.to_rgb.join(',')}, 0.8);"
  end

  def background_body_style
    "background-color: rgba(#{color.to_rgb.join(',')}, 0.5);"
  end

  def font_class
    if color.darkish?
      'text-white'
    else
      'text-dark'
    end
  end

  private

  def attachment_summary_component_args
    {
      audio_count: audio_attachment_count,
      image_count: image_attachment_count,
      video_count: video_attachment_count,
      all_count: attachment_count,
      font_class:
    }
  end

  def sanitize_preview(content)
    sanitize(
      content,
      tags: %w[div i span turbo-frame],
      attributes: %w[class data-controller data-attachment-icon-target id loading role src title]
    )
  end

  def attachment_icon(attachment_data)
    attachment_data.symbolize_keys!
    render(
      AttachmentIconComponent.new(
        **attachment_data.slice(:content_type),
        blob_id: attachment_data.fetch(:id)
      )
    )
  end
end
