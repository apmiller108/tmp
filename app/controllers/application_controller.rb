class ApplicationController < ActionController::Base
  include Dry::Effects::Handler.Reader(:current_user)

  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, if: :json_request?

  around_action :set_current_user

  private

  def json_request?
    request.format.json?
  end

  def set_current_user
    with_current_user(current_user) { yield }
  end
end
