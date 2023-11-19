class UserComponent < ApplicationViewComponent
  delegate :email, to: :@user

  def initialize(user:)
    @user = user
  end
end
