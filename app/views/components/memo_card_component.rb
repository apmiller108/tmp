# frozen_string_literal: true

class MemoCardComponent < ApplicationViewComponent
  with_collection_parameter :memo

  attr_reader :memo

  delegate :content, :title, to: :memo

  def initialize(memo:)
    @memo = memo
  end

  def preview_text
    content.to_plain_text.truncate_words(10)
  end
end
