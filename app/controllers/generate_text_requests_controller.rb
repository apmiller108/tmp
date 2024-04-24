class GenerateTextRequestsController < ApplicationController
  def create
    generatate_text_request = current_user.generate_text_requests.create(generate_text_request_params)

    respond_to do |format|
      format.turbo_stream do
        if generatate_text_request.persisted?
          GenerateTextJob.perform_async(generatate_text_request.id)
          head :created
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def generate_text_request_params
    params.require(:generate_text_request).permit(:prompt, :text_id, :temperature, :generate_text_preset_id)
  end
end
