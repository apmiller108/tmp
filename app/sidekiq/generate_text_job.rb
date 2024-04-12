class GenerateTextJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  def perform(generate_text_request_id)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    response = invoke_model(generate_text_request)

    if response
      broadcast_content(generate_text_request, response)
    else
      broadcast_error(generate_text_request)
      broadcast_flash(generate_text_request.user)
    end
  end

  private

  def broadcast_content(generate_text_request, model_response)
    MyChannel.broadcast_to(generate_text_request.user, {
      generate_text: { text_id: generate_text_request.text_id, content: model_response.content, error: nil }
    })
  end

  def broadcast_error(generate_text_request)
    MyChannel.broadcast_to(generate_text_request.user, {
      generate_text: { text_id: generate_text_request.text_id, content: nil, error: true }
    })
  end

  def broadcast_flash(user)
    flash.alert = I18n.t('unable_to_generate_text')
    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:memos]],
      component: FlashMessageComponent.new(flash:),
      action: :replace
    )
  end

  def invoke_model(generate_text_request)
    client = GenerativeText::Anthropic::Client.new
    GenerativeText.new(client).invoke_model(
      **generate_text_request.slice(:prompt, :temperature, :system_message).symbolize_keys,
      max_tokens: 500
    )
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    false
  end
end
