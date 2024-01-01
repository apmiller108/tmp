class TranscriptionSummaryJob
  include Sidekiq::Job

  SUMMARY_PROMPT = <<~PROMPT.freeze
    Summarize the following transcription into a series of bullet points:

    "%s"
  PROMPT


  def perform(user_id, transcription_id)
    user = User.find(user_id)
    transcription = user.transcriptions.find(transcription_id)
    # TODO: Create summary model. Polymorphic belongs to summarizable.
    # summary = transcription.build_summary

    LLMService.invoke_model_stream(prompt: SUMMARY_PROMPT % transcription.content) do |stream_response|
      # summary.content += stream_response.content
      # TODO create summary component
      # TODO broadcast summary component turbo stream
      # summary.save! if stream_response.final_chunk?
    end
  end
end
