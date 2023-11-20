# frozen_string_literal: true

class InlineEditComponent < ApplicationViewComponent
  attr_reader :model, :attribute, :id

  renders_one :model_attribute

  def initialize(model:, attribute:, id:)
    @model = model
    @attribute = attribute
    @id = id
  end

  def frame_id
    "turbo_frame_#{id}_#{attribute}"
  end

  def edit_path
    edit_polymorphic_path(model)
  end

  def edit_link_text
    "#{t('edit')} #{t(attribute)}"
  end
end
