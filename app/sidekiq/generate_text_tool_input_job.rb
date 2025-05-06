class GenerateTextToolInputJob
  include Sidekiq::Job
  include Flashable

  def perform(generate_text_request_id)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    return unless generate_text_request.response.tool_use?

    handle_inputs(generate_text_request)
  rescue StandardError => e
    message = I18n.t('unable_to_generate_image')
    broadcast_flash_to_user(message:, user: generate_text_request.user) if generate_text_request
    Rails.logger.warn "#{self.class}: #{e} : generate_text_request_id: #{generate_text_request_id}"
  end

  private

  def handle_inputs(generate_text_request)
    generate_text_request.response.tool_inputs.each do |tool_input|
      handler = LlmTool.handler_for(tool_input)
      unless handler.call(generate_text_request)
        log_and_broadcast_errors(generate_text_request.user, handler)
      end
    end
  end

  def log_and_broadcast_errors(user, handler)
    message = I18n.t('llm_tool_failed', handler_name: handler.class.to_s.split('::').last)
    broadcast_flash_to_user(message:, user:)
    Rails.logger.warn "#{self.class}: #{message}"
  end
end
