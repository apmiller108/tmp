# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WysiwygEditorComponent, type: :component do
  subject { page }

  let(:form) { instance_double(ActionView::Helpers::FormBuilder) }
  let(:rich_text_field_id) { 'obj_content_trix_input_obj_1' }
  let(:rich_text_field) { :content }
  let(:rich_text_area) do
    "<input type='hidden' name='obj[content]' id='#{rich_text_field_id}'>".html_safe
  end
  let(:component) { described_class.new(form:, rich_text_field:) }

  before do
    allow(form).to receive(:rich_text_area).with(rich_text_field).and_return(rich_text_area)
    render_inline component
  end

  it { is_expected.to have_css '.c-wysiwyg-editor' }

  it 'renders the rich text field' do
    expect(page).to have_css "input##{rich_text_field_id}", visible: :hidden
  end
end
