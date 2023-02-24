module BetterRailsSystemTests
  def take_screenshot
    return super unless Capybara.last_used_session

    Capybara.using_session(Capybara.last_used_session) { super }
  end

  # Relative image paths in screenshot message since docker absolute paths
  # differ from local
  def image_path
    Pathname.new(absolute_image_path).relative_path_from(Rails.root).to_s
  end
end

RSpec.configure do |c|
  c.include BetterRailsSystemTests, type: :system

  c.around(:each, type: :system) do |ex|
    original_host = Rails.application.default_url_options[:host]
    Rails.application.default_url_options[:host] = Capybara.server_host
    ex.run
    Rails.application.default_url_options[:host] = original_host
  end

  c.prepend_before(:each, type: :system) do
    driven_by Capybara.javascript_driver
  end
end
