# frozen_string_literal: true

class MemoFormComponent < ApplicationViewComponent
  attr_reader :memo

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

  def default_color
    memo.class::SWATCHES[:swatch1].last
  end

  def color_picker_options
    {
      align: :left,
      input_name: "#{memo.model_name.element}[color]"
    }
  end
end
