# frozen_string_literal: true

class InlineFieldComponent < ApplicationViewComponent
  attr_reader :model, :attribute, :form

  renders_one :field_slot

  def initialize(model:, attribute:, form:)
    @model = model
    @attribute = attribute
    @form = form
  end

  def frame_id
    InlineEditComponent.turbo_frame_id(model, attribute)
  end
end
