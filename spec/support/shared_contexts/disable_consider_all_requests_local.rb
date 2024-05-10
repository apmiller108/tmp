# Use this in request specs to have ActiveRecord::RecordNotFound errors result
# in 404 responses
RSpec.shared_context 'with disable consider all requests local' do
  before do
    method = Rails.application.method(:env_config)
    allow(Rails.application).to receive(:env_config).with(no_args) do
      method.call.merge(
        'action_dispatch.show_exceptions' => :rescuable,
        'action_dispatch.show_detailed_exceptions' => false,
        'consider_all_requests_local' => false
      )
    end
  end
end
