class WysiwygEditorComponent < ApplicationViewComponent
  attr_reader :object, :method

  # @param object [Object] ActiveRecord object
  # @param method [Symbol | String] the returns the content of the editor

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

  def gen_image_aspect_ratio_options_json
    GenerativeImage::Stability::CORE_ASPECT_RATIOS.map do |ar|
      { value: ar, label: ar, selected: ar == '1:1' }
    end.to_json
  end

  def gen_text_preset_options_json
    GenerateTextPreset.all.map { |p| { value: p.id, label: p.name.titleize, temperature: p.temperature.to_s } }.to_json
  end

  def gen_text_temperature_options_json
    0.step(to: 1, by: 0.1).map { |n| { value: n.round(1).to_s, label: n.round(1).to_s } }.to_json
  end

  def conversation
    object.conversation if object.respond_to? :conversation
  end
end
