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
end
