# frozen_string_literal: true

class ClipboardComponent < ApplicationViewComponent
  renders_one :copyable

  attr_reader :css_class

  def initialize(css_class = 'clipboard')
    @css_class = css_class
  end
end
