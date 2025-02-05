require 'vips'

class GenerateImageJob
  include Sidekiq::Job
  include Flashable

  sidekiq_options retry: false

  # rubocop:disable Metrics/AbcSize
  def perform(generate_image_request_id)
    request = GenerateImageRequest.find(generate_image_request_id)
    request.in_progress!

    broadcast_component(request.conversation_turn, request.user, action: :append, target: 'conversation-turns')

    response = generate_image(request)
    payload = { generate_image: { image_name: request.image_name, image: nil, content_type: nil, error: nil } }

    if response&.image_present?
      attach_to_request(request, response.image)
      request.completed!
      broadcast_response(request, payload, response)
    else
      request.failed!
      broadcast_error(request, payload)
    end
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    request.failed!
    broadcast_error(request, payload)
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

  def broadcast_response(request, payload, response)
    conversation_turn = request.conversation_turn

    if conversation_turn
      broadcast_component(conversation_turn, request.user)
    else
      broadcast_image(request.user, payload, response.image)
    end
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

  def broadcast_component(conversation_turn, user, **options)
    return if conversation_turn.nil?

    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:main]],
      component: ConversationTurnComponent.new(conversation_turn:),
      action: options.fetch(:action, :replace),
      **options
    )
  end

  def broadcast_error(request, payload)
    conversation_turn = request.conversation_turn

    if conversation_turn
      broadcast_component(conversation_turn, request.user)
    else
      payload[:generate_image][:error] = true
      MyChannel.broadcast_to(request.user, payload)
    end
    broadcast_flash(user)
  end

  def broadcast_flash(user)
    message = I18n.t('unable_to_generate_image')
    broadcast_flash_to_user(user:, message:)
  end
end
