require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'

ENV['AWS_ACCESS_KEY'] = 'aws-access_key_id'
ENV['AWS_SECRET_KEY'] = 'aws-secret_key_id'
ENV['AWS_REGION'] = 'aws-region'
ENV['AWS_BUCKET'] = 'aws-bucket'
ENV['ANTHROPIC_KEY'] = 'anthropic_key'
ENV['DEVISE_JWT_KEY'] = '5c2bfb28d566bd3aff8e3d5571803149648215d6bfe2f24e2290d9ba15acd73f1fa0bcaa16817dc0db5f8b96da74e2a598806c436dce999327d82c89245fee4f'
ENV['GITHUB_ID'] = 'github_id'
ENV['GITHUB_SECRET'] = 'github_secret'
ENV['POSTGRES_HOST'] = 'database'
ENV['POSTGRES_USER'] = 'postgres'
ENV['POSTGRES_PASSWORD'] = 'postgres'
ENV['REDIS_URL'] = 'redis://redis:6379/1'
ENV['SECRET_KEY_BASE'] = 'e58ce2d32d05cb26d6d46882be63932f5d35e2f71523e67b5a6ebe40652259d50bf85886a5580b6c2b22138597962ae483a3e51aae31bce18355471318e036d9'
ENV['STABILITY_KEY'] = 'stability_key'
ENV['VOYAGE_API_KEY'] = 'voyage api key'

require_relative '../config/environment'
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'sidekiq_unique_jobs/testing'
require 'view_component/test_helpers'
require 'view_component/system_test_helpers'
require_relative 'support/request_stubs'
require 'capybara/rspec'
require 'webmock/rspec'
require 'active_support/testing/time_helpers'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

Rails.application.default_url_options[:host] = 'http://www.example.com'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ENV.fetch('CHROME_URL', 'http://chrome:3333')
)

RSpec.configure do |config|
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include ActiveSupport::Testing::TimeHelpers
  config.include RequestStubs

  config.include AuthHeader, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Turbo::TestAssertions, type: :request

  config.include ViewComponent::TestHelpers, type: :component
  config.include ViewComponent::SystemTestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component
  config.include Dry::Effects::Handler.Reader(:current_user), type: :component
  config.include Rails.application.routes.url_helpers, type: :component

  config.before(:suite) do
    SidekiqUniqueJobs.config.enabled = false # prevents sidekiq-unique-jobs from attempting to connect with redis
  end
end
