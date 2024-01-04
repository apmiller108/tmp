require 'rails_helper'

RSpec.describe Transcription, type: :model do
  describe '#to_text' do
    subject(:transcription) do
      build(:transcription, content: 'Sample content', summary:)
    end

    let(:summary) { build_stubbed :summary, content: 'Sample summary' }
    let(:speaker_content) { instance_double(Transcription::SpeakerContent, squash: [item1, item2]) }
    let(:item1) { instance_double(Transcription::SpeakerContent::Item, to_text: 'Speaker 1: content1') }
    let(:item2) { instance_double(Transcription::SpeakerContent::Item, to_text: 'Speaker 2: content2') }

    before do
      allow(Transcription::SpeakerContent).to receive(:new).and_return(speaker_content)
    end

    it 'returns the expected text format' do
      expected_text = <<~TEXT.strip
        Text:

        Sample content

        Speaker ID:

        Speaker 1: content1
        Speaker 2: content2

        Summary:

        Sample summary
      TEXT

      expect(transcription.to_text).to eq(expected_text)
    end

    context 'without a summary' do
      let(:summary) { nil }

      it 'does not include the summary section' do
        expected_text = <<~TEXT.strip
          Text:

          Sample content

          Speaker ID:

          Speaker 1: content1
          Speaker 2: content2
        TEXT

        expect(transcription.to_text).to eq(expected_text)
      end
    end
  end
end
