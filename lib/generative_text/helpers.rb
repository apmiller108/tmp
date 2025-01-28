class GenerativeText
  module Helpers
    MARKDOWN_FORMAT_SYSTEM_MESSAGE = <<~TXT
      You always answer the with markdown formatting which can inlcude headings,
      bold, italic, links, tables, lists, code blocks, and blockquotes.
    TXT

    SUMMARY_TEMPLATE = <<~PROMPT.strip.freeze
      %<preamble>sSummarize the %<description>s below.

      "%<content>s"
    PROMPT

    def self.transcription_summary_prompt(transcription)
      template_vars = if transcription.speakers.count > 1
                        {
                          preamble: "The following is a dialogue between #{transcription.speakers.to_sentence}. ",
                          description: :dialogue,
                          content: transcription.diarized_results_to_text
                        }
                      else
                        { preamble: '',  description: :transcription, content: transcription.content }
                      end
      SUMMARY_TEMPLATE % template_vars
    end

    def self.markdown_sys_msg
      MARKDOWN_FORMAT_SYSTEM_MESSAGE
    end
  end
end
