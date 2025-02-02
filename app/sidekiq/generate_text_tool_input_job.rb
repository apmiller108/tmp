class GenerateTextToolInputJob
  include Sidekiq::Job
  include Flashable

  def perform(generate_text_request_id)
    generate_text_request = GenerateTextRequest.find(generate_text_request_id)
    return unless generate_text_request.response.tool_use?

    handle_imge_inputs(generate_text_request)
  rescue StandardError => e
    message = I18n.t('unable_to_generate_image')
    broadcast_flash_to_user(message:, user: generate_text_request.user)
    Rails.logger.warn "#{self.class}: #{e} : generate_text_request_id: #{generate_text_request.id}"
  end

  private

  def handle_imge_inputs(generate_text_request)
    generate_text_request.response.generate_image_inputs.each do |input|
      user = generate_text_request.user
      attrs = input['options'].merge(input['prompts']).merge(user:)
      form = GenerateImageRequestForm.new(attrs)

      if form.submit
        GenerateImageJob.perform_async(form.generate_image_request.id)
      else
        log_and_broadcast_errors(user, form)
      end
    end
  end

  def log_and_broadcast_errors(user, form)
    message = I18n.t('unable_to_generate_image')
    broadcast_flash_to_user(message:, user:, record: form)
    Rails.logger.warn "#{self.class}: form_errors : #{form.errors.full_messages}"
  end
end
