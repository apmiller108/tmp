class ApplicationController < ActionController::Base
  include Dry::Effects::Handler.Reader(:current_user)

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, if: :json_request?

  around_action :provide_current_user, if: :current_user

  rescue_from ActionController::InvalidAuthenticityToken, with: :forbidden

  private

  def json_request?
    request.format.json?
  end

  def provide_current_user(&block)
    with_current_user(current_user, &block)
  end

  def forbidden
    head :forbidden
  end
end
