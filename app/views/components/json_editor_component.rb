# frozen_string_literal: true

class JsonEditorComponent < ApplicationViewComponent
  attr_reader :form, :placeholder, :helper_text, :css_class

  def initialize(form:, placeholder: '', helper_text: '', css_class: '')
    @form = form
    @placeholder = placeholder
    @helper_text = helper_text
    @css_class = css_class
  end
end
