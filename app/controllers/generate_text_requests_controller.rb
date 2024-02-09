class GenerateTextRequestsController < ApplicationController
  def create
    respond_to do |format|
      format.turbo_stream do
        generatate_text_request = current_user.generate_text_requests.create(generate_text_request_params)
        if generatate_text_request
          # GenerateTextJob.perform_async(text_id, current_user.id)
          render turbo_stream: turbo_stream.replace(text_id, model_response.content), status: :created
        else
          flash.now.alert = 'Unable to generate text'
          render turbo_stream: turbo_stream.update('alert-stream', FlashMessageComponent.new(flash:)),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def generate_text_request_params
    params.require(:generate_text_request).permit(:prompt, :text_id)
  end

  def invoke_model
    GenerativeText.new.invoke_model(
      prompt: generative_text_params[:input],
      temp: 0.3,
      max_tokens: 500
    )
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    false
  end
end
