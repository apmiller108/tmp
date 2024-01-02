class TranscriptionSummaryJob
  include Sidekiq::Job

  SUMMARY_PROMPT = <<~PROMPT.freeze
    Summarize the transcription below into a series of statements deliminated by "*" character.

    "%s"
  PROMPT

  def perform(user_id, transcription_id)
    user = User.find(user_id)
    transcription = user.transcriptions.find(transcription_id)
    summary = transcription.summary

    summary.in_progress!

    # @stream_response [InvokeModelStreamResponse, #content, #final_chunk?]
    LLMService.new.invoke_model_stream(prompt: SUMMARY_PROMPT % transcription.content) do |stream_response|
      summary.content += stream_response.content

      if stream_response.final_chunk?
        summary.status = Summary.statuses[:completed]
        summary.save!
      end

      ViewComponentBroadcaster.call(
        [user, TurboStreams::STREAMS[:blobs]],
        component: TranscriptionSummaryComponent.new(transcription:),
        action: :replace
      )
    end
  end
end
