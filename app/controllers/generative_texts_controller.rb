class GenerativeTextsController < ApplicationController
  def create
    respond_to do |format|
      format.turbo_stream do
        model_response = invoke_model
        if model_response
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

  def generative_text_params
    params.require(:generative_text).permit(:input, :text_id)
  end

  def text_id
    generative_text_params[:text_id]
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
