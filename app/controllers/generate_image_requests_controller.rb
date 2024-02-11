class GenerateImageRequestsController < ApplicationController
  def create
    form = GenerateImageRequestForm.new(generate_image_request_params)

    respond_to do |format|
      format.turbo_stream do
        if form.submit
          # GenerateImageJob.perform_async(form.generate_text_request.id)
          head :created
        else
          flash.now.alert = t('unable_to_generate_image')
          flash_component = FlashMessageComponent.new(flash:)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def generate_image_request_params
    params.require(:generaete_image_request).permit(:image_id, :style, :dimensions, prompts: %i[text weight])
  end
end
