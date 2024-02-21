class GenerateImageJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  def perform(generate_image_request_id)
    request = GenerateImageRequest.find(generate_image_request_id)
    response = generate_image(request.parameterize)

    payload = { generate_image: { image_id: request.image_id, image: nil, error: nil } }

    if response&.image_present?
      broadcast_image(request.user, payload, response)
    else
      broadcast_error(request.user, payload)
    end
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    broadcast_flash(request.user)
  end

  private

  def generate_image(params)
    GenerativeImage.new.text_to_image(**params)
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    nil
  end

  def broadcast_image(user, payload, response)
    payload[:generate_image][:image] = response.base64
    MyChannel.broadcast_to(user, payload)
  end

  def broadcast_error(user, payload)
    payload[:generate_image][:error] = true
    MyChannel.broadcast_to(user, payload)
    broadcast_flash(user)
  end

  def broadcast_flash(user)
    flash.alert = I18n.t('unable_to_generate_text')
    ViewComponentBroadcaster.call([user, TurboStreams::STREAMS[:memos]],
                                  component: FlashMessageComponent.new(flash:),
                                  action: :replace)
  end
end
