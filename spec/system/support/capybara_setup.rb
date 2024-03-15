# See also https://www.rubydoc.info/gems/capybara/Capybara#configure-class_method

Capybara.default_max_wait_time = 2

# Normalize whitespace when using text matchers.
Capybara.default_normalize_ws = true

# Disable CSS transitions/animations
Capybara.disable_animation = true

# For screenshots and downloads
Capybara.save_path = './tmp/capybara'

# Make service accessible from outside
Capybara.server_host = '0.0.0.0'

# Shell out `hostname` for docker network resolvable name
Capybara.app_host = "http://#{ENV.fetch('APP_HOST', `hostname`.strip&.downcase || '0.0.0.0')}"

# For multiple browser sessions in a single test
Capybara.singleton_class.prepend(
  Module.new do
    attr_accessor :last_used_session

    def using_session(name, &block)
      self.last_used_session = name
      super
    ensure
      self.last_used_session = nil
    end
  end
)
