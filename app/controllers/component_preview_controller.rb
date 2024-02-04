class ComponentPreviewController < ApplicationController
  include ViewComponent::PreviewActions

  skip_before_action :authenticate_user!

  def current_user
    User.last
  end
end
