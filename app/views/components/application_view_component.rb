class ApplicationViewComponent < ViewComponent::Base
  include Dry::Effects.Reader(:current_user, default: nil)

  # See https://viewcomponent.org/compatibility.html#actiontext
  delegate :rich_text_area_tag, to: :helpers
end
