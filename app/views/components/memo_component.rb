class MemoComponent < ApplicationViewComponent
  attr_reader :memo

  delegate :color, to: :memo
  delegate :to_rgb, to: :@color

  def initialize(memo:)
    @memo = memo
    @color = Color.new(memo.color)
  end

  def id
    dom_id(memo)
  end

  def border_styles
    return if @color.default?

    "box-shadow: 0 0 0.5rem 0.5rem rgba(#{to_rgb.join(',')}, 0.5); "\
    "border: 0.25rem solid rgba(#{to_rgb.join(',')}, 0.8);"
  end
end
