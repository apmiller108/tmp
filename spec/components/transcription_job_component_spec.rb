require "rails_helper"

RSpec.describe TranscriptionJobComponent, type: :component do
  subject { page }

  let(:user) { build_stubbed :user }
  let(:component) { described_class.new(transcription_job:) }
  let(:transcription_job) { build_stubbed :transcription_job, status: }

  before do
    with_current_user(user) do
      render_inline(component)
    end
  end

  context 'when the job is in progress' do
    let(:status) { TranscriptionJob.statuses[:in_progress] }

    it { is_expected.to have_css '.alert-info', text: 'Transcription in progress' }
  end

  context 'when the job is completed' do
    let(:status) { TranscriptionJob.statuses[:completed] }

    it 'has a link to the transcription' do
      expect(page).to have_link 'Transcription completed', href: user_transcription_job_transcriptions_path(user, transcription_job)
    end
  end

  context 'when the job is failed' do
    let(:status) { TranscriptionJob.statuses[:failed] }

    it { is_expected.to have_css '.alert-warning', text: 'Transcription failed' }
  end
end
