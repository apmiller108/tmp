class GenerativeTextsController < ApplicationController
  def create
    respond_to do |format|
      format.turbo_stream do
        if true
          render turbo_stream: 'Here is your text, dummy!',
                 status: :created
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
end
