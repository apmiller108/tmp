source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

gem 'anycable-rails', '~> 1.4'
gem 'aws-sdk-bedrockruntime', require: false
gem 'aws-sdk-s3', require: false
gem 'aws-sdk-transcribeservice', require: false
gem 'bootsnap', require: false
gem 'commonmarker'
gem 'cssbundling-rails'
gem 'devise'
gem 'devise-jwt'
gem 'dry-effects'
gem 'faraday'
gem 'faraday-multipart'
gem 'haml'
gem 'image_processing', '~> 1.2'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'jwt'
gem 'omniauth-github', '~> 2.0.0'
gem 'omniauth-rails_csrf_protection'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rack-cors'
gem 'rails', '~> 7.1'
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.0'
gem 'sidekiq-cron', '~> 1.12'
gem 'sidekiq-unique-jobs', '~> 8.0'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby] # For platforms without zoneinfo files
gem 'view_component'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '~> 6.2'
  gem 'rspec-rails', '~> 6.0'
end

group :development do
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
  gem 'dockerfile-rails', '~> 1.2'
  gem 'hotwire-livereload'
  gem 'rubocop', '~> 1.44', require: false
  gem 'rubocop-performance', '~> 1.15', require: false
  gem 'rubocop-rails', '~> 2.17', require: false
  gem 'rubocop-rspec', '~> 2.18', require: false
  gem 'spring'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'cuprite'
  gem 'faker'
  gem 'webmock'
end
