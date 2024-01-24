require 'capybara/cuprite'

# Configure a driver
Capybara.register_driver(:better_cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1200, 800],
    browser_options: { 'no-sandbox' => nil },
    process_timeout: 10, # Chrome startup wait time. Might need to increase on CI.
    timeout: 10,
    inspector: true, # Enable debugging
    headless: !ENV['HEADLESS'].in?(%w[0 false]),
    slowmo: ENV['SLOMO']&.to_f,
    url: ENV.fetch('CHROME_URL', 'http://chrome:3333')
  )
end

# Use the driver by default
Capybara.default_driver = Capybara.javascript_driver = :better_cuprite

module CupriteHelpers
  def pause
    page.driver.pause
  end

  def debug(binding = nil)
    $stdout.puts 'Open Chrome inspector at http://localhost:3333'
    return binding.break if binding

    page.driver.pause
  end
end

RSpec.configure do |c|
  c.include CupriteHelpers, type: :system
end
