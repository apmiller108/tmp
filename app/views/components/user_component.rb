class UserComponent < ApplicationViewComponent
  delegate :email, to: :@user
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def setting
    user.setting || user.build_setting
  end
end
