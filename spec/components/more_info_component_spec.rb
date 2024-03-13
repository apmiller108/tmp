require 'rails_helper'

RSpec.describe MoreInfoComponent, type: :component do
  subject { page }

  let(:id) { 'more-info' }
  let(:src) { 'http://example.com/stuff' }
  let(:component) { described_class.new(id:, src:) }

  before do
    component.with_wrapped { 'WRAPPED' }
    render_inline(component)
  end

  it { is_expected.to have_css '.c-more-info[data-controller="more-info"]' }
  it { is_expected.to have_css '.content[data-more-info-target="content"]' }

  it 'renders a lazy turbo frame element' do
    expect(page).to have_css "turbo-frame##{id}[src='#{src}'][loading='lazy']"
  end

  it { is_expected.to have_css 'button[data-more-info-target="button"]' }

  it 'renders the wrapped slot' do
    expect(page).to have_content 'WRAPPED'
  end
end
