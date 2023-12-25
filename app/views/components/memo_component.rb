class MemoComponent < ApplicationViewComponent
  attr_reader :memo

  def initialize(memo:)
    @memo = memo
  end

  def id
    dom_id(memo)
  end
end
