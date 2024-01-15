class ApplicationViewComponent < ViewComponent::Base
  include Dry::Effects.Reader(:current_user, default: nil)
  include Rails.application.routes.url_helpers
  include Turbo::FramesHelper

  # See https://viewcomponent.org/compatibility.html#actiontext
  delegate :rich_text_area_tag, to: :helpers
end
