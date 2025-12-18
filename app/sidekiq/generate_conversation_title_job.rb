class GenerateConversationTitleJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options lock: :until_executed

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    request = GenerateTextRequest.create!(markdown_format: false,
                                          user: conversation.user,
                                          prompt: GenerativeText::Helpers.conversation_title_prompt(conversation),
                                          temperature: 0.2,
                                          model: GenerativeText::SUMMARY_MODEL.api_name)

    response = GenerativeText.new.invoke_model(request)
    request.update!(response: response.data, status: GenerateTextRequest.statuses[:completed])
    # truncate title to 100 characters
    conversation.update!(title: response.content.strip.truncate(100, omission: ''))

    broadcast_render(conversation)
  rescue StandardError => e
    broadcast_flash_to_user(message: 'Unable to generate title', user: conversation.user)
    Rails.logger.warn("#{self.class}: #{e.message}")
  end

  private

  def broadcast_render(conversation)
    Turbo::StreamsChannel.broadcast_action_to(
      [conversation.user, TurboStreams::STREAMS[:main]],
      target: 'conversation-title',
      partial: 'conversations/title_form',
      locals: { conversation: },
      action: :replace
    )
    Turbo::StreamsChannel.broadcast_action_to(
      [conversation.user, TurboStreams::STREAMS[:main]],
      target: ApplicationHelper.list_dom_id(conversation),
      partial: 'conversations/list_item',
      formats: [:turbo_stream],
      locals: { conversation: },
      action: :replace
    )
  end
end
