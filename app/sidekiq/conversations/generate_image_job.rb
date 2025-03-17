require 'vips'

module Conversations
  class GenerateImageJob
    include Sidekiq::Job
    include Flashable
    include ActionView::RecordIdentifier

    sidekiq_options retry: false

    # rubocop:disable Metrics/AbcSize
    def perform(generate_image_request_id)
      request = GenerateImageRequest.find(generate_image_request_id)
      request.in_progress!

      broadcast_component(request.conversation_turn, request.user, action: :append, target: 'conversation-turns')
      broadcast_nav(request, request.user)

      response = generate_image(request)

      if response&.image_present?
        attach_to_request(request, response.image)
        request.completed!
        broadcast_component(request.conversation_turn, request.user)
      else
        request.failed!
        broadcast_error(request)
      end
    rescue StandardError => e
      Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
      request.failed!
      broadcast_error(request)
    end
    # rubocop:enable Metrics/AbcSize

    private

    def generate_image(request)
      params = request.parameterize
      GenerativeImage.new.perform_request(**params)
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

    def broadcast_component(conversation_turn, user, **options)
      ViewComponentBroadcaster.call(
        [user, TurboStreams::STREAMS[:main]],
        component: ConversationTurnComponent.new(conversation_turn:),
        action: options.fetch(:action, :replace),
        **options
      )
    end

    def broadcast_nav(request, user)
      ViewComponentBroadcaster.call(
        [user, TurboStreams::STREAMS[:main]],
        component: ScrollspyNavItemComponent.new(text: request.prompt,
                                                 icon_class: 'bi-file-earmark-image',
                                                 href: "##{dom_id(request.conversation_turn)}",
                                                 id: dom_id(request.conversation_turn, 'nav_item')),
        action: :append,
        target: ScrollspyComponent::ITEMS_CONTAINER_ID
      )
    end

    def broadcast_error(request)
      broadcast_component(request.conversation_turn, request.user)
      broadcast_flash(request.user)
    end

    def broadcast_flash(user)
      message = I18n.t('unable_to_generate_image')
      broadcast_flash_to_user(user:, message:)
    end
  end
end
