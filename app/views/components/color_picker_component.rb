# frozen_string_literal: true

class ColorPickerComponent < ApplicationViewComponent
  attr_reader :swatches, :default_color, :opts

  def initialize(swatches:, default_color: nil, **opts)
    @swatches = swatches
    @default_color = default_color
    @opts = opts
  end

  def align = opts.fetch(:align, :center)
  def input_name = opts.fetch(:input_name, :color)

  def swatch_styles
    {
      left: 'left: -13rem;',
      center: 'left: -6.5rem;'
    }.fetch(align, '')
  end

  def button_styles
    if default_color
      "background: ##{default_color};"
    else
      'color: #000;'
    end
  end
end
