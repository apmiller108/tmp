class GenerativeTextsController < ApplicationController
  def create
    respond_to do |format|
      format.turbo_stream do
        llm_response = invoke_llm
        if llm_response
          render turbo_stream: turbo_stream.replace(text_id, llm_response.content), status: :created
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

  def invoke_llm
    LLMService.new.invoke_model(
      prompt: generative_text_params[:input],
      temp: 0.3,
      max_tokens: 500
    )
  rescue StandardError => e
    Rails.logger.warn("#{self.class}: #{e} : #{e.cause}")
    false
  end
end
