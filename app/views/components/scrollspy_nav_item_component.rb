# frozen_string_literal: true

class ScrollspyNavItemComponent < ApplicationViewComponent
  attr_reader :text, :tooltip, :icon_class, :href

  def initialize(text:, tooltip:, icon_class:, href:)
    @text = text
    @tooltip = tooltip
    @icon_class = icon_class
    @href = href
  end
end
