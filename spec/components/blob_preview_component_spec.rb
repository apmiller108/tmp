require 'rails_helper'

RSpec.describe BlobPreviewComponent, type: :component do
  subject { page }

  let(:component) { described_class.new(blob:) }
  let(:blob) { build_stubbed :active_storage_blob, content_type: }
  let(:content_type) { 'foo/bar' }
  let(:spinner_component) do
    Class.new(ApplicationViewComponent) do
      haml_template <<~HAML
        SPINNER_COMPONENT
      HAML
    end
  end

  before do
    stub_const('SpinnerComponent', spinner_component)
    allow(SpinnerComponent).to receive(:new).and_call_original
    render_inline component
  end

  it { is_expected.to have_css '.c-blob-preview[data-controller="blob-preview"]' }
  it { is_expected.to have_content blob.filename.to_s }

  context 'with an image' do
    let(:content_type) { 'image/png' }

    it 'renders the SpinnerComponent' do
      expect(page).to have_content 'SPINNER_COMPONENT'
    end

    it 'renders the image' do
      expect(page).to have_css "img[title='#{blob.filename}']"
    end
  end
end
