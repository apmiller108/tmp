class MemoComponent < ApplicationViewComponent
  include MemoColor

  attr_reader :memo

  delegate :color, to: :memo

  def initialize(memo:)
    @memo = memo
  end

  def id
    dom_id(memo)
  end
end
