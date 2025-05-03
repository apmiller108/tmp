# frozen_string_literal: true

class JsonEditorComponent < ApplicationViewComponent
  attr_reader :form, :field_name, :placeholder, :helper_text, :css_class

  def initialize(form:, field_name:, placeholder: '', helper_text: '', css_class: '')
    @form = form
    @field_name = field_name
    @placeholder = placeholder
    @helper_text = helper_text
    @css_class = css_class
  end

  def value
    form.object.public_send(field_name).to_json
  end
end
