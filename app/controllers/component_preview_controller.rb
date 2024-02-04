class ComponentPreviewController < ApplicationController
  include Dry::Effects::Handler.Reader(:current_user)

  include ViewComponent::PreviewActions

  around_action :provide_current_user

  def current_user
    User.last
  end

  def provide_current_user(&block)
    with_current_user(current_user, &block)
  end
end
