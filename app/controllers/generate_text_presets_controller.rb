class GenerateTextPresetsController < ApplicationController
  def index
    @generate_text_presets = current_user.generate_text_presets.order(:updated_at)
  end

  def show
  end

  def new
    @generate_text_preset = current_user.generate_text_presets.new
  end

  def create
    @generate_text_preset = current_user.generate_text_presets.new(generate_text_preset_params.merge(preset_type: :custom))
    respond_to do |format|
      if @generate_text_preset.save
        current_user.generate_text_presets << @generate_text_preset
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

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def generate_text_preset_params
    params.require(:generate_text_preset).permit(:name, :description, :system_message, :temperature)
  end
end
