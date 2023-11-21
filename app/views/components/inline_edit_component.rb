# frozen_string_literal: true

class InlineEditComponent < ApplicationViewComponent
  extend ActionView::RecordIdentifier

  attr_reader :model, :attribute

  renders_one :field_slot

  def self.turbo_frame_id(model, attribute)
    id = if model.respond_to?(:map)
           model.map { |m| dom_id(m) }.join('_')
         else
           dom_id(model)
         end
    "turbo_frame_#{id}_#{attribute}"
  end

  def initialize(model:, attribute:)
    @model = model
    @attribute = attribute
  end

  def frame_id
    self.class.turbo_frame_id(model, attribute)
  end

  def edit_path
    edit_polymorphic_path(model)
  end

  def edit_link_text
    "#{t('edit')} #{t(attribute)}"
  end
end
