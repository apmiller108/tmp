require 'rails_helper'

RSpec.describe TranscriptionComponent, type: :component do
  let(:user) { build :user, id: 1 }
  let(:component) { described_class.new(transcription:) }
  let(:transcription_job) { build_stubbed :transcription_job, :completed }
  let(:transcription) { build_stubbed :transcription, transcription_job:, id: 2 }

  before do
    with_current_user(user) do
      render_inline(component)
    end
  end

  it 'shows the transcription collapse button' do
    expect(page).to have_css("button[id='transcription_job_#{transcription_job.id}']",
                             text: 'Transcription completed')
  end

  it 'shows the transcript' do
    expect(page).to have_content(transcription.content)
  end

  it 'has a link to download the transcript' do
    expect(page).to have_link 'Download',
                              href: user_transcription_download_path(user, transcription_id: transcription.id)
  end

  context 'with diarized results' do
    let(:transcription_job) do
      build_stubbed :transcription_job, :completed,
                    response: JSON.parse(file_fixture('transcription/response_diarized.json').read)
    end

    it 'shows the diarized results' do
      transcription.diarized_results.each do |result|
        expect(page).to have_text result.content
      end
    end
  end
end
