class GenerateTextPresetsController < ApplicationController
  def index
    @generate_text_presets = current_user.generate_text_presets.order(updated_at: :desc)
  end

  def new
    @generate_text_preset = current_user.generate_text_presets.new
    @redirect_after_create = params[:redirect_after_create]
  end

  def create
    @generate_text_preset = current_user.generate_text_presets.new(
      generate_text_preset_params.merge(preset_type: :custom)
    )
    respond_to do |format|
      if @generate_text_preset.save
        current_user.generate_text_presets << @generate_text_preset
        format.turbo_stream do
          redirect_to after_create_redirect_path(@generate_text_preset), status: :see_other
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_save', model_name: 'Preset')
          flash_component = FlashMessageComponent.new(flash:, record: @generate_text_preset)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @generate_text_preset = current_user.generate_text_presets.find(params[:id])
  end

  def update
    @generate_text_preset = current_user.generate_text_presets.find(params[:id])
    respond_to do |format|
      if @generate_text_preset.update(generate_text_preset_params)
        format.turbo_stream do
          redirect_to generate_text_presets_path, status: :see_other
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_save', model_name: 'Preset')
          flash_component = FlashMessageComponent.new(flash:, record: @generate_text_preset)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @generate_text_preset = current_user.generate_text_presets.find(params[:id])
    respond_to do |format|
      if @generate_text_preset.destroy
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(@generate_text_preset)
        end
      else
        format.turbo_stream do
          flash.now.alert = 'Unable to delete preset'
          flash_component = FlashMessageComponent.new(flash:)

          render turbo_stream: turbo_stream.update(flash_component.id, flash_component),
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def after_create_redirect_path(preset)
    if params[:redirect_after_create]
      "#{params[:redirect_after_create]}?text_preset_id=#{preset.id}"
    else
      generate_text_presets_path
    end
  end

  def generate_text_preset_params
    params.require(:generate_text_preset).permit(:name, :description, :system_message, :temperature)
  end
end
