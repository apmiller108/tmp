class GenerativeText
  module Prompt
    SUMMARY_TEMPLATE = <<~PROMPT.strip.freeze
      %<preamble>sSummarize the %<description>s below.

      "%<content>s"
    PROMPT

    def self.transcription_summary_prompt(transcription)
      template_vars = if transcription.speakers.count > 1
                        {
                          content: transcription.diarized_results_to_text,
                          description: :dialogue,
                          preamble: "The following is a dialogue between #{transcription.speakers.to_sentence}. "
                        }
                      else
                        { content: transcription.content, description: :transcription, preamble: '' }
                      end
      SUMMARY_TEMPLATE % template_vars
    end
  end
end
