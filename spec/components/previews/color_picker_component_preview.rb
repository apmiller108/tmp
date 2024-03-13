class ColorPickerComponentPreview < ViewComponent::Preview
  DEFAULT_PATH = 'rails/view_components/color_picker_component/default'.freeze
  def default
    render ColorPickerComponent.new(swatches: Memo::SWATCHES, selected_color: nil, align: :end)
  end
end
