require 'rails_helper'

RSpec.describe AttachmentIconComponent, type: :component do
  subject { page }

  let(:component) { described_class.new(blob_id:, content_type:) }
  let(:blob_id) { 99 }
  let(:content_type) { 'something/else' }

  before do
    render_inline component
  end

  it { is_expected.to have_css 'i.c-attachment-icon.bi.bi-file-earmark[data-controller="attachment-icon"]' }

  it 'render a lazy loading turbo frame' do
    expect(page).to have_css "turbo-frame#blob_preview_#{blob_id}[loading='lazy'][src='#{blob_preview_path(blob_id)}']"
  end

  context 'with an image content type' do
    let(:content_type) { 'image/png' }

    it 'renders the proper icon' do
      expect(page).to have_css 'i.bi.bi-file-earmark-image'
    end
  end
end
