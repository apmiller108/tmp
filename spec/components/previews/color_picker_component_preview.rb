class ColorPickerComponentPreview < ViewComponent::Preview
  # rails/view_components/color_picker_component/default
  def default
    render ColorPickerComponent.new(swatches: Memo::SWATCHES, default_color: Memo::SWATCHES[:swatch1][0])
  end
end
