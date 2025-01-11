# frozen_string_literal: true

class ClipboardComponent < ApplicationViewComponent
  renders_one :copyable
  renders_one :sibling

  attr_reader :css_class, :position

  def initialize(css_class: 'clipboard', position: :top)
    @css_class = css_class
    @position = position
  end

  def tip
    t('copy')
  end

  def top?
    position == :top
  end

  def bottom?
    position == :bottom
  end
end
