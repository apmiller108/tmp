class GenerateTextJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  def perform(generate_text_request_id)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    user = generate_text_request.user
    response = invoke_model(generate_text_request)

    if response
      generate_text_request.update!(response: response.data)
      broadcast_content(generate_text_request, user, response.content)
    else
      broadcast_error(generate_text_request, user)
      broadcast_flash_error(user)
    end
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    broadcast_error(generate_text_request, user)
    broadcast_flash_error(user)
  end

  private

  def broadcast_content(generate_text_request, user, content)
    MyChannel.broadcast_to(user, {
      generate_text: { **generate_text_request.slice(:text_id, :conversation_id, :user_id), content:, error: nil }
    })
    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:main]],
      component: ConversationTurnComponent.new(Conversation::Turn.for_response(content)),
      target: ConversationTurnComponent::PENDING_RESPONSE_DOM_ID,
      action: :replace
    )
  end

  def broadcast_error(generate_text_request, user)
    MyChannel.broadcast_to(user, {
      generate_text: { text_id: generate_text_request.text_id, content: nil, error: true }
    })
  end

  def broadcast_flash_error(user)
    flash.alert = I18n.t('unable_to_generate_text')
    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:main]],
      component: FlashMessageComponent.new(flash:),
      action: :update
    )
  end

  def invoke_model(generate_text_request)
    client = GenerativeText::Anthropic::Client.new
    GenerativeText.new(client).invoke_model(
      **generate_text_request.slice(:prompt, :temperature, :system_message, :model).symbolize_keys,
      messages: generate_text_request.conversation.exchange,
      max_tokens: 500
    )
  end
end
