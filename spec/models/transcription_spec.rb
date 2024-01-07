require 'rails_helper'

RSpec.describe Transcription, type: :model do
  describe '#speaker_content' do
    subject(:transcription) { build(:transcription, transcription_job:).speaker_content }

    let(:items) { double }
    let(:transcription_job) { build_stubbed :transcription_job }

    before do
      allow(transcription_job).to receive(:items).and_return(items)
      allow(described_class::SpeakerContent).to receive(:new).with(items).and_call_original
    end

    it { is_expected.to be_a described_class::SpeakerContent }
  end

  describe '#diarized_results_to_text' do
    let(:items) { [item1, item2] }
    let(:item1) { instance_double Transcription::SpeakerContent::Item, to_text: 'foo' }
    let(:item2) { instance_double Transcription::SpeakerContent::Item, to_text: 'bar' }
    let(:speaker_content) { instance_double Transcription::SpeakerContent, squash: items }

    before do
      allow(described_class::SpeakerContent).to receive(:new).and_return(speaker_content)
    end

    it 'retuns the text representation of each item joins by a newline' do
      transcription = build :transcription
      expect(transcription.diarized_results_to_text).to eq ("#{item1.to_text}\n#{item2.to_text}")
    end
  end

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
