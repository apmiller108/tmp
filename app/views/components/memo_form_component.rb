# frozen_string_literal: true

class MemoFormComponent < ApplicationViewComponent
  attr_reader :memo

  delegate :color, to: :memo
  alias default_color color

  def initialize(memo:)
    @memo = memo
  end

  def id
    dom_id(memo)
  end

  def submit_value
    memo.persisted? ? t('memo.update') : t('memo.create')
  end

  def swatches
    memo.class::SWATCHES
  end

  def color_picker_options
    {
      align: :left,
      input_name: "#{memo.model_name.element}[color]"
    }
  end

  def color_style
    return unless color.present?

    "box-shadow: 0 0 0.5rem 0.5rem rgba(#{rgb}, 0.5); border: 0.25rem solid rgba(#{rgb}, 0.8);"
  end

  private

  def rgb
    r = color[0..1].to_i(16)
    g = color[2..3].to_i(16)
    b = color[4..5].to_i(16)
    [r, g, b].join(',')
  end
end
