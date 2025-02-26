# frozen_string_literal: true

class ScrollspyNavItemComponent < ApplicationViewComponent
  attr_reader :text, :tooltip, :icon_class, :href

  def initialize(text:, icon_class:, href:)
    @text = text
    @icon_class = icon_class
    @href = href
  end

  def nav_text
    truncate(text, length: 20, separator: ' ')
  end

  def tooltip_text
    truncate(text, length: 300, separator: ' ')
  end
end
