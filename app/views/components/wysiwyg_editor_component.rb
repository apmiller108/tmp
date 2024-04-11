class WysiwygEditorComponent < ApplicationViewComponent
  attr_reader :object, :method

  # @param object [Object] ActiveRecord object
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
    GenerativeImage::Stability::STYLE_PRESETS.map do |preset|
      { value: preset, label: preset.tr('-', ' ').titleize, selected: preset == 'photographic' }
    end.to_json
  end

  def gen_image_dimension_options_json
    GenerativeImage::Stability::DIMENSIONS.map do |dimension|
      { value: dimension, label: dimension, selected: dimension == '320x320' }
    end.to_json
  end

  def gen_text_preset_options_json
    GenerativeTextPreset.all.map { |p| { value: p.id, label: p.name.titleize } }.to_json
  end
end
