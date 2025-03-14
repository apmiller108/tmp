class GenerateTextJob
  include Sidekiq::Job
  include Dry::Effects::Handler.Reader(:current_user)
  include ActionView::RecordIdentifier
  extend Flashable

  sidekiq_options retry: 1

  # @param generate_text_request_id [Integer] the primary key of the request record
  # @param stream [Boolean] switch to stream response vs one full response
  def perform(generate_text_request_id, stream)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    user = generate_text_request.user

    generate_text_request.in_progress!
    response = if stream
                 invoke_model_stream(generate_text_request)
               else
                 invoke_model(generate_text_request)
               end

    generate_text_request.update!(response: response.data, status: GenerateTextRequest.statuses[:completed])
    broadcast_component(generate_text_request, user)
    broadcast_content(generate_text_request, user, response.content)

    GenerateTextToolInputJob.perform_async(generate_text_request_id) if response.tool_use?
  end

  private

  def broadcast_content(generate_text_request, user, content)
    conversation_id = generate_text_request.conversation_id
    MyChannel.broadcast_to(user, {
      generate_text: { **generate_text_request.slice(:text_id, :user_id), conversation_id:, content:, error: nil }
    })
  end

  def broadcast_component(generate_text_request, user)
    conversation = generate_text_request.conversation.reload
    conversation_turn = generate_text_request.conversation_turn

    ViewComponentBroadcaster.call(
      [user, TurboStreams::STREAMS[:main]],
      component: ConversationTurnComponent.new(conversation_turn:),
      action: :replace
    )

    with_current_user(user) do
      ViewComponentBroadcaster.call(
        [user, TurboStreams::STREAMS[:main]],
        component: PromptFormComponent.new(conversation_form: ConversationForm.new(user:, conversation:)),
        action: :replace
      )
    end
  end

  def invoke_model(generate_text_request)
    GenerativeText.new.invoke_model(generate_text_request)
  end

  def invoke_model_stream(generate_text_request)
    assistant_response = ''
    message_count = 0
    GenerativeText.new.invoke_model_stream(generate_text_request) do |text|
      message_count += 1
      assistant_response += text
      if (message_count % 5).zero?
        ViewComponentBroadcaster.call(
          [generate_text_request.user, TurboStreams::STREAMS[:main]],
          component: MarkdownToHtmlComponent.new(markdown: assistant_response),
          action: :update,
          target: dom_id(generate_text_request, 'assistant_response')
        )
      end
    end
  end

  class << self
    def on_retries_exhausted(generate_text_request_id)
      generate_text_request = GenerateTextRequest.find(generate_text_request_id)
      user = generate_text_request.user

      generate_text_request.failed!

      ViewComponentBroadcaster.call(
        [user, TurboStreams::STREAMS[:main]],
        component: ConversationTurnComponent.new(conversation_turn: generate_text_request.conversation_turn),
        action: :replace
      )

      MyChannel.broadcast_to(user, {
        generate_text: { text_id: generate_text_request.text_id, content: nil, error: true }
      })

      message = I18n.t('unable_to_generate_text')
      broadcast_flash_to_user(message:, user:)
    end
  end

  sidekiq_retries_exhausted do |job, _ex|
    Rails.logger.warn("#{job['class']}: failed with #{job['args']} : #{job['error_message']}")
    on_retries_exhausted(job['args'][0])
  end
end
