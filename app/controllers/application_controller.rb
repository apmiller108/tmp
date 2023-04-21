class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def authenticate_user!
    if request.format.json?
      # TODO: authenticate_with_jwt
    else
      super
    end
  end
end
