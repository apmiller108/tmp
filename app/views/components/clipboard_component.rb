# frozen_string_literal: true

class ClipboardComponent < ApplicationViewComponent
  renders_one :copyable
  renders_one :additional_content

  attr_reader :css_class, :x, :y

  def initialize(css_class: 'clipboard', y: :top, x: :end)
    @css_class = css_class
    @y = y
    @x = x
  end

  def tip
    t('copy')
  end

  def top?
    y == :top
  end

  def bottom?
    y == :bottom
  end

  def end?
    x == :end
  end

  def start?
    x == :start
  end
end
