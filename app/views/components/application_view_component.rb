class ApplicationViewComponent < ViewComponent::Base
  include Dry::Effects.Reader(:current_user, default: nil)
  include Rails.application.routes.url_helpers

  # See https://viewcomponent.org/compatibility.html#actiontext
  delegate :rich_text_area_tag, :turbo_frame_tag, to: :helpers
end
