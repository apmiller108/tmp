class WysiwygEditorComponentPreview < ViewComponent::Preview

  # rails/view_components/wysiwyg_editor_component/new
  def new
    render WysiwygEditorComponent.new(object: Memo.new, method: 'content')
  end

  # rails/view_components/wysiwyg_editor_component/edit
  def edit
    memo = Memo.last
    raise 'No memos found. See at least one memo to view the edit version' if memo.blank?
    render WysiwygEditorComponent.new(object: memo, method: 'content')
  end
end
