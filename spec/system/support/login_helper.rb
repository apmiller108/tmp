module LoginHelper
  def login(user:)
    visit 'users/sign_in'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
  end
end

RSpec.configure do |c|
  c.include LoginHelper, type: :system
end
