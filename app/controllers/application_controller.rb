class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, if: :json_request?

  private

  def json_request?
    request.format.json?
  end
end
