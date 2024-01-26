class WysiwygEditorComponent < ApplicationViewComponent
  attr_reader :form, :rich_text_field

  # @param form [ActionView::Helpers::FormBuilder]
  def initialize(form: nil, rich_text_field: nil)
    @form = form
    @rich_text_field = rich_text_field
  end
end
