class TranscriptionSummaryJob
  include Sidekiq::Job

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def perform(user_id, transcription_id)
    user = User.find(user_id)
    transcription = user.transcriptions.find(transcription_id)
    summary = transcription.summary
    prompt = GenerativeText.summary_prompt_for(transcription:)
    client = GenerativeText::AWS::Client.new

    summary.in_progress!

    # @stream_response [InvokeModelStreamResponse, #content, #final_chunk?]
    GenerativeText.new.invoke_model_stream(client:, prompt:) do |stream_response|
      summary.content += stream_response.content

      if stream_response.final_chunk?
        summary.status = Summary.statuses[:completed]
        summary.save!
      end

      ViewComponentBroadcaster.call(
        [user, TurboStreams::STREAMS[:memos]],
        component: TranscriptionSummaryComponent.new(transcription:),
        action: :replace
      )
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : transcription_id: #{transcription_id}; user_id: #{user_id}")
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
end
