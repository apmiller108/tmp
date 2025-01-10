class SettingsController < ApplicationController
  def create
    setting = current_user.build_setting(setting_params)
    if setting.save
      flash[:notice] = t('successfully_saved', model_name: 'Setting')
    else
      flash[:alert] = 'unable to save setting'
    end
    redirect_to root_path
  end

  def update
    setting = current_user.setting
    if setting.update(setting_params)
      flash[:notice] = t('successfully_saved', model_name: 'Setting')
    else
      flash[:alert] = 'unable to save setting'
    end
    redirect_to root_path
  end

  private

  def setting_params
    params.require(:setting).permit(:text_model)
  end
end
