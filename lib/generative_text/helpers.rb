class GenerativeText
  module Helpers
    MARKDOWN_FORMAT_SYSTEM_MESSAGE = <<~TXT.freeze
      You always answer the with markdown formatting which can inlcude headings,
      bold, italic, links, tables, lists, code blocks, and blockquotes. If the
      user asks you to produce a diagram, always use mermaid syntax. Never
      explain your syntax choices when producing a mermaid diagram.
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
                        { preamble: '', description: :transcription, content: transcription.content }
                      end
      SUMMARY_TEMPLATE % template_vars
    end

    def self.markdown_sys_msg
      MARKDOWN_FORMAT_SYSTEM_MESSAGE
    end

    def self.conversation_title_prompt(conversation)
      instructions = 'Create a brief title for the following conversation. Only return the title, '\
                     'without any quotation marks. Do not prefix the title with \"Title:\".'
      <<~PROMPT
        #{instructions}

        #{conversation.blobify[0..(GenerateTextRequest::MAX_PROMPT_LENGTH - instructions.length - 4)]}
      PROMPT
    end
  end
end
