require 'rails_helper'

RSpec.describe InlineFieldComponent, type: :component do
  subject { page }

  let(:form) { instance_double(ActionView::Helpers::FormBuilder, submit: '<input type="submit">'.html_safe) }
  let(:model) { build_stubbed :user }
  let(:attribute) { :foo }
  let(:field) { 'FIELD' }
  let(:turbo_frame_id) { 'frame_id' }
  let(:component) do
    described_class.new(model:, attribute:, form:).tap do |c|
      c.with_field_slot { field }
    end
  end

  before do
    allow(InlineEditComponent).to receive(:turbo_frame_id).with(model, attribute).and_return(turbo_frame_id)
    render_inline component
  end

  it { is_expected.to have_css "turbo-frame[id='#{turbo_frame_id}']" }

  it 'renders the field slot' do
    expect(page).to have_content field
  end

  it 'renders a submit inline action' do
    within('.inline-action') do
      expect(page).to have_css 'input[type="submit"]'
    end
  end

  it 'renders a cancel link inline action' do
    within('.inline-action') do
      expect(page).to have_link 'Cancel', href: polymorphic_path(model)
    end
  end
end
