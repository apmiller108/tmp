class TranscriptionSummaryJob
  include Sidekiq::Job

  def perform(user_id, transcription_id)
    user = User.find(user_id)
    transcription = user.transcriptions.find(transcription_id)
    summary = transcription.summary

    summary.in_progress!

    LLMService.summary_prompt_for(transcription:)

    # @stream_response [InvokeModelStreamResponse, #content, #final_chunk?]
    LLMService.new.invoke_model_stream(prompt: LLMService.summary_prompt_for(transcription:)) do |stream_response|
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
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : transcription_id: #{transcription_id}; user_id: #{user_id}")
  end
end
