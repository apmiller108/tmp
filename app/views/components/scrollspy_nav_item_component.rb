# frozen_string_literal: true

class ScrollspyNavItemComponent < ApplicationViewComponent
  attr_reader :text, :tooltip, :icon_class, :href, :id

  def initialize(text:, icon_class:, href:, id:)
    @text = text
    @icon_class = icon_class
    @href = href
    @id = id
  end

  def nav_text
    truncate(text, length: 25, separator: ' ')
  end

  def tooltip_text
    truncate(text, length: 300, separator: ' ')
  end
end
