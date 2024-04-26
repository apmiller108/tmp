class GenerateTextJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  def perform(generate_text_request_id)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    user = generate_text_request.user
    response = invoke_model(generate_text_request)

    if response
      broadcast_content(generate_text_request, user, response)
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

  def broadcast_content(generate_text_request, user, model_response)
    MyChannel.broadcast_to(user, {
      generate_text: { text_id: generate_text_request.text_id, content: model_response.content, error: nil }
    })
  end

  def broadcast_error(generate_text_request, user)
    MyChannel.broadcast_to(user, {
      generate_text: { text_id: generate_text_request.text_id, content: nil, error: true }
    })
  end

  def broadcast_flash_error(user)
    flash.alert = I18n.t('unable_to_generate_text')
    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:memos]],
      component: FlashMessageComponent.new(flash:),
      action: :update
    )
  end

  def invoke_model(generate_text_request)
    client = GenerativeText::Anthropic::Client.new
    GenerativeText.new(client).invoke_model(
      **generate_text_request.slice(:prompt, :temperature, :system_message).symbolize_keys,
      messages: generate_text_request.conversation.exchange,
      max_tokens: 500
    )
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    false
  end
end
