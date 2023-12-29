# frozen_string_literal: true

require "rails_helper"

RSpec.describe TranscriptionComponent, type: :component do
  let(:user) { build :user, id: 1 }
  let(:component) { described_class.new(transcription_job:) }
  let(:status) { TranscriptionJob.statuses[:in_progress] }
  let(:transcription_job) { build_stubbed :transcription_job, status: }

  before do
    with_current_user(user) do
      render_inline(component)
    end
  end

  it 'shows the transcription status button' do
    expect(page).to have_css("button[id='transcription_job_#{transcription_job.id}']",
                             text: 'Transcription in progress')
  end

  context 'with a completed transcription' do
    let(:transcription_job) { build_stubbed :transcription_job, :completed, :with_blob, transcription: }
    let(:transcription) { build_stubbed :transcription, :with_blob, id: 2 }

    it 'shows the transcript' do
      expect(page).to have_content(transcription.content)
    end

    it 'has a link to download the transcript' do
      expect(page).to have_link 'Download',
                                href: user_transcription_download_path(user, transcription_id: transcription.id)
    end
  end
end
