class GenerateImageJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  def perform(generate_image_request_id)
    request = GenerateImageRequest.find(generate_image_request_id)
    image = generate_image(request.parameterize)

    payload = { generate_image: { image_id: request.image_id, image:, error: nil } }

    if image
      MyChannel.broadcast_to(request.user, payload)
    else
      payload[:generate_image][:error] = true
      MyChannel.broadcast_to(request.user, payload)
      broadcast_flash(request.user)
    end
  end

  private

  def generate_image(params)
    GenerativeImage.new.text_to_image(params)
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    nil
  end

  def broadcast_flash(user)
    flash.alert = I18n.t('unable_to_generate_text')
    ViewComponentBroadcaster.call([user, TurboStreams::STREAMS[:memos]],
                                  component: FlashMessageComponent.new(flash:),
                                  action: :replace)
  end
end
