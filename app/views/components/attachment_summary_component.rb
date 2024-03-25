# frozen_string_literal: true

class AttachmentSummaryComponent < ApplicationViewComponent
  attr_reader :all_count, :audio_count, :image_count, :video_count, :font_class

  def initialize(audio_count: rand(5), image_count: rand(5), video_count: rand(5), all_count: audio_count + image_count + video_count + rand(5), font_class:)
    @all_count = all_count
    @audio_count = audio_count
    @image_count = image_count
    @video_count = video_count

    @font_class = font_class
  end

  def other_count
    all_count - audio_count - image_count - video_count
  end

  def counts
    {
      audio_count:,
      image_count:,
      video_count:,
      other_count:
    }.select { |_k, v| v.positive? }
  end

  private

  def icon_class(count_type)
    case count_type
    when :image_count
      'bi bi-file-earmark-image'
    when :video_count
      'bi bi-file-earmark-play'
    when :audio_count
      'bi bi-file-earmark-music'
    when :other_count
      'bi bi-file-earmark'
    else
      'bi bi-file-earmark'
    end
  end
end
