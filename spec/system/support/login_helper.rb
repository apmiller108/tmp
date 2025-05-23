module LoginHelper
  def login(user:)
    visit 'users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end

  def navigate_to(path)
    visit path
    page.driver.resize(1440, 900)
  end
end

RSpec.configure do |c|
  c.include LoginHelper, type: :system
end
