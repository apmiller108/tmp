class MemoFormComponentPreview < ViewComponent::Preview
  DEFAULT_PATH = 'rails/view_components/memo_form_component/default'.freeze
  def default
    memo = Memo.new
    render_with_template(
      locals: {
        memo:
      }
    )
  end
end
