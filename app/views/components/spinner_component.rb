# frozen_string_literal: true

class SpinnerComponent < ApplicationViewComponent
  attr_reader :css_class, :attributes

  def initialize(css_class: '', **attributes)
    @css_class = css_class
    @attributes = attributes
  end
end
