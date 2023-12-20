require 'rails_helper'

RSpec.describe TranscriptionJob, type: :model do
  it 'declares status enum' do
    expect(described_class.statuses).to eq({
      "created"=>"created", "queued"=>"queued", "in_progress"=>"in_progress", "failed"=>"failed", "completed"=>"completed"
    })
  end

  describe '#results' do
    let(:response) { JSON.parse(file_fixture('transcription/response_toxicity.json').read) }
    subject { described_class.new(response:) }

    it 'returns the transcript' do
      expect(subject.results).to eq response['results']['transcripts'][0]['transcript']
    end
  end
end
