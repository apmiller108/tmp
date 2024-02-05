require 'rails_helper'

RSpec.describe GenerativeText::Prompt do
  describe '.transcription_summary_prompt' do
    let(:transcription) { build(:transcription, content: 'Sample transcription') }

    context 'when there is more than one speaker' do
      it 'generates a summary prompt with dialogue preamble and diarized results' do
        allow(transcription).to receive(:speakers).and_return(%w[Speaker1 Speaker2])
        allow(transcription).to receive(:diarized_results_to_text).and_return('Diarized results')

        expected_prompt = <<~PROMPT.strip
          The following is a dialogue between Speaker1 and Speaker2. Summarize the dialogue below.

          "Diarized results"
        PROMPT

        result = described_class.transcription_summary_prompt(transcription)
        expect(result).to eq(expected_prompt)
      end
    end

    context 'when there is only one speaker' do
      it 'generates a summary prompt without dialogue preamble' do
        allow(transcription).to receive(:speakers).and_return(['Speaker1'])

        expected_prompt = <<~PROMPT.strip
          Summarize the transcription below.

          "Sample transcription"
        PROMPT

        result = described_class.transcription_summary_prompt(transcription)
        expect(result).to eq(expected_prompt)
      end
    end
  end
end
