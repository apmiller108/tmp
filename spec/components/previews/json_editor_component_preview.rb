class JsonEditorComponentPreview < ViewComponent::Preview
  EDIT_PATH = 'rails/view_components/json_editor_component/edit'.freeze

  # View templates in sidecar folder
  def edit
    render_with_template(
      locals: {
        model: OpenStruct.new(json_field: nil)
      }
    )
  end
end
