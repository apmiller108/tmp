class WysiwygEditorComponentPreview < ViewComponent::Preview
  NEW_PATH = 'rails/view_components/wysiwyg_editor_component/new'.freeze
  EDIT_PATH = 'rails/view_components/wysiwyg_editor_component/edit'.freeze

  # View templates in sidecar folder
  def new
    render_with_template(
      locals: {
        user: User.new(id: 1),
        memo: Memo.new
      }
    )
  end

  def edit
    memo = Memo.last
    raise 'No memos found. See at least one memo to view the edit version' if memo.blank?

    render_with_template(
      locals: {
        user: User.new(id: 1),
        memo:
      }
    )
  end
end
