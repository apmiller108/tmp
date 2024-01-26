class WysiwygEditorComponent < ApplicationViewComponent
  attr_reader :object, :method

  # @param object [Object]
  # @param method [Symbol | String]
  def initialize(object:, method:)
    @object = object
    @method = method
  end

  def rich_text_area_name
    "#{object.model_name.element}[#{method}]"
  end

  def rich_text_area_value
    object.public_send(method)
  end
end
