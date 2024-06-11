require 'vips'

class GenerateImageJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  # rubocop:disable Metrics/AbcSize
  def perform(generate_image_request_id)
    request = GenerateImageRequest.find(generate_image_request_id)
    response = generate_image(request)

    payload = { generate_image: { image_name: request.image_name, image: nil, content_type: nil, error: nil } }

    if response&.image_present?
      attach_to_request(request, response.image)
      broadcast_image(request.user, payload, response.image)
    else
      broadcast_error(request.user, payload)
    end
    rescue StandardError => e
      Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
      broadcast_flash(request.user)
  end
  # rubocop:enable Metrics/AbcSize

  private

  def generate_image(request)
    params = request.parameterize
    GenerativeImage.new.text_to_image(**params)
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    nil
  end

  def attach_to_request(generate_image_request, png)
    generate_image_request.image.attach(
      io: ImageProcessing::Vips.source(Vips::Image.new_from_buffer(png, '')).saver(strip: true).call,
      filename: "#{generate_image_request.image_name}.png",
      content_type: 'image/png'
    )
  end

  # @param [User] user
  # @param [Hash] payload
  # @param [String] png the raw image bytes
  def broadcast_image(user, payload, png)
    webp = ImageProcessing::Vips.source(Vips::Image.new_from_buffer(png, '')).convert!('webp') # Tempfile
    payload[:generate_image][:image] = Base64.encode64(webp.read)
    payload[:generate_image][:content_type] = 'image/webp'
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
