class SettingsController < ApplicationController
  def create
    setting = current_user.build_setting(setting_params)
    setting.save
    redirect_to root_path
  end

  def update
    setting = current_user.setting
    setting.update(setting_params)
    redirect_to root_path
  end

  private

  def setting_params
    params.require(:setting).permit(:text_model)
  end
end
