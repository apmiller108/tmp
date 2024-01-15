# frozen_string_literal: true

class MemoCardComponent < ApplicationViewComponent
  with_collection_parameter :memo

  attr_reader :memo

  delegate :content, :title, to: :memo

  def initialize(memo:)
    @memo = memo
  end

  def id
    "card_#{dom_id(memo)}"
  end

  def preview_text
    content.to_plain_text.truncate_words(10)
  end

  def expanded_preview_text
    content.to_plain_text.truncate_words(30)
  end

  def created_at
    time_ago_in_words(memo.created_at)
  end

  def updated_at
    time_ago_in_words(memo.updated_at)
  end
end
