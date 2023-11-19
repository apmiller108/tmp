class ApplicationViewComponent < ViewComponent::Base
  include Dry::Effects.Reader(:current_user, default: nil)
end
