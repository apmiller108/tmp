class GenerateTextRequestsController < ApplicationController
  def create
    respond_to do |format|
      format.turbo_stream do
        generatate_text_request = current_user.generate_text_requests.create(generate_text_request_params)
        if generatate_text_request
          GenerateTextJob.perform_async(generatate_text_request.id)
          head :created
        else
          flash.now.alert = t('unable_to_generate_text')
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
end
