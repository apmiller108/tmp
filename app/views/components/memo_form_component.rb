# frozen_string_literal: true

class MemoFormComponent < ApplicationViewComponent
  attr_reader :memo

  delegate :color, to: :memo

  def initialize(memo:)
    @memo = memo
  end

  def id
    dom_id(memo)
  end

  def submit_value
    memo.persisted? ? t('memo.update') : t('memo.create')
  end

  def selected_color
    color.hex unless color.default?
  end

  def color_picker_options
    {
      swatches: memo.class::SWATCHES,
      selected_color:,
      align: :left,
      input_name: "#{memo.model_name.element}[color]"
    }
  end

  def border_styles
    return if color.default?

    "box-shadow: 0 0 0.5rem 0.5rem rgba(#{color.to_rgb.join(',')}, 0.5); "\
    "border: 0.25rem solid rgba(#{color.to_rgb.join(',')}, 0.8);"
  end
end
