# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WysiwygEditorComponent, type: :component do
  subject { page }

  let(:obj_name) { 'obj_name' }
  method = 'content'
  value = 'obj value'

  let(:object) do
    name = instance_double(ActiveModel::Name, element: obj_name)
    Class.new do
      define_method(:model_name) do
        name
      end

      define_method(method) do
        value
      end
    end.new
  end

  let(:component) { described_class.new(object:, method:) }

  before do
    render_inline component
  end

  it { is_expected.to have_css '.c-wysiwyg-editor' }

  it 'renders rich text hidden input with the proper attributes' do
    expect(page).to have_css "input[name='#{obj_name}[#{method}]'][value='#{value}']", visible: :hidden
  end
end
