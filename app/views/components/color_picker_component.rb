# frozen_string_literal: true

class ColorPickerComponent < ApplicationViewComponent
  attr_reader :swatches, :default_color

  def initialize(swatches:, default_color:)
    @swatches = swatches
    @default_color = default_color
  end
end
