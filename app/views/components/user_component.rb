class UserComponent < ViewComponent::Base
  delegate :email, to: :@user

  def initialize(user:)
    @user = user
  end
end
