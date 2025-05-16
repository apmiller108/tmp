class TranscriptionSummaryJob
  include Sidekiq::Job

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def perform(user_id, transcription_id)
    user = User.find(user_id)
    transcription = user.transcriptions.find(transcription_id)
    summary = transcription.summary
    prompt = GenerativeText.summary_prompt_for(transcription:)
    request = GenerateTextRequest.create!(prompt:,
                                          user:,
                                          model: GenerativeText::SUMMARY_MODEL.api_name,
                                          temperature: 0.2)
    summary.in_progress!

    # @text_content [String]
    response = GenerativeText.new.invoke_model_stream(request) do |text|
      summary.content += text
      broadcast(user, transcription)
    end

    if response.complete?
      request.update(response: response.data, status: GenerateTextRequest.statuses[:completed])
      summary.status = Summary.statuses[:completed]
      summary.save!
      broadcast(user, transcription)
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("#{self.class}: #{e} : transcription_id: #{transcription_id}; user_id: #{user_id}")
  end
  # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

  private

  def broadcast(user, transcription)
    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:memos]],
      component: TranscriptionSummaryComponent.new(transcription:),
      action: :replace
    )
  end
end
