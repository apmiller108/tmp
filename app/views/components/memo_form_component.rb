# frozen_string_literal: true

class MemoFormComponent < ApplicationViewComponent
  include MemoColor

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

  def default_color
    color || swatches[:swatch1].first
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
end
