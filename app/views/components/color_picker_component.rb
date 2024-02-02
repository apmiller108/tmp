# frozen_string_literal: true

class ColorPickerComponent < ApplicationViewComponent
  attr_reader :swatches, :selected_color, :opts

  def initialize(swatches:, selected_color: nil, **opts)
    @swatches = swatches
    @selected_color = selected_color
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
    if selected_color
      "background: ##{selected_color};"
    else
      'color: #000;'
    end
  end
end
