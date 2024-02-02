# frozen_string_literal: true

class MemoCardComponent < ApplicationViewComponent
  with_collection_parameter :memo

  attr_reader :memo

  delegate :content, :title, to: :memo

  def initialize(memo:)
    @memo = memo
    @color = Color.new(memo.color)
  end

  def id
    "card_#{dom_id(memo)}"
  end

  def preview_text
    content.to_plain_text.truncate_words(25, omission: '')
  end

  def continued_preview_text
    content.to_plain_text.gsub(preview_text, '').truncate_words(30)
  end

  def created_at
    time_ago_in_words(memo.created_at)
  end

  def updated_at
    time_ago_in_words(memo.updated_at)
  end

  def background_style
    "background-color: rgba(#{@color.to_rgb.join(',')}, 0.8);"
  end

  def background_body_style
    "background-color: rgba(#{@color.to_rgb.join(',')}, 0.5);"
  end

  def font_class
    if @color.to_rgb.sum < (255 * 3) / 3.7
      'text-white'
    else
      'text-dark'
    end
  end
end
