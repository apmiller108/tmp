# frozen_string_literal: true

require "rails_helper"

RSpec.describe TranscriptionComponent, type: :component do
  let(:component) { described_class.new(transcription_job:) }
  let(:status) { TranscriptionJob.statuses[:in_progress] }
  let(:transcription_job) { build_stubbed :transcription_job, status: }

  before do
    render_inline(component)
  end

  it 'shows the transcription status button' do
    expect(page).to have_css("button[id='transcription_job_#{transcription_job.id}']", text: 'Transcription in progress')
  end

  context 'with a completed transcription' do
    let(:transcription_job) { build_stubbed :transcription_job, :completed, transcription: }
    let(:transcription) { build_stubbed :transcription }

    it 'shows the transcript' do
      expect(page).to have_content(transcription.content)
    end
  end
end
