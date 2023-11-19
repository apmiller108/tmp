class UserComponent < ApplicationViewComponent
  delegate :email, to: :@user
  attr_reader :user

  def initialize(user:)
    @user = user
  end
end
