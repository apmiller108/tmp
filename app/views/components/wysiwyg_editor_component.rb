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

  def gen_image_style_options_json
    JSON.dump(
      GenerativeImage::Stability::STYLE_PRESETS.map do |preset|
        { value: preset, label: preset.tr('-', ' ').titleize }
      end
    )
  end

  def gen_image_dimension_options_json
    JSON.dump(
      GenerativeImage::Stability::DIMENSIONS
    )
  end
end
