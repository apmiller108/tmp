class GenerateTextJob
  include Sidekiq::Job

  sidekiq_options retry: false

  def perform(generate_text_request_id)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    response = invoke_model(prompt: generate_text_request.prompt)

    if response
      broadcast_content(generate_text_request, response)
    else
      broadcast_flash(generate_text_request.user)
    end
  end

  private

  def broadcast_content(generate_text_request, model_response)
    Turbo::StreamsChannel.broadcast_action_to(
      [generate_text_request.user, TurboStreams::STREAMS[:memos]],
      target: generate_text_request.text_id,
      content: model_response.content,
      action: :replace
    )
  end

  def broadcast_flash(user)
    flash.alert = I18n.t('unable_to_generate_text')
    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:memos]],
      component: FlashMessageComponent.new(flash:),
      action: :replace
    )
  end

  def flash
    @flash ||= Struct.new('Flashy', :alert).new
  end

  def invoke_model(prompt:)
    GenerativeText.new.invoke_model(
      prompt:,
      temp: 0.3,
      max_tokens: 500
    )
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    false
  end
end
