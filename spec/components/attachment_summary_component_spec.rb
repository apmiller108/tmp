require 'rails_helper'

RSpec.describe AttachmentSummaryComponent, type: :component do
  subject { page }

  let(:component) { described_class.new(all_count: 5, audio_count: 2, image_count: 1, video_count: 0, font_class:) }
  let(:font_class) { 'foo-class' }

  before do
    render_inline component
  end

  it { is_expected.to have_css '.c-attachment-summary[data-controller="attachment-summary"]' }

  it { is_expected.to have_css 'button[data-bs-title="1 image"]' }
  it { is_expected.to have_css 'i.bi.bi-file-earmark-image' }

  it { is_expected.to have_css 'button[data-bs-title="2 audios"]' }
  it { is_expected.to have_css 'i.bi.bi-file-earmark-music' }

  it { is_expected.to have_css 'button[data-bs-title="2 files"]' }
  it { is_expected.to have_css 'i.bi.bi-file-earmark' }
end
