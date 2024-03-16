# frozen_string_literal: true

class SpinnerComponent < ApplicationViewComponent
  attr_reader :css_class

  def initialize(css_class: '')
    @css_class = css_class
  end
end
