require "system_helper"

RSpec.describe 'logging in', type: :system do
  let(:password) { 'Password' }
  let!(:user) { create :user, password: }

  specify 'user logs in' do
    visit '/'
    expect(page).to have_current_path('/users/sign_in')
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Log in'
    expect(page).to have_text 'Signed in successfully'
    expect(page).to have_current_path('/')
    expect(page).to have_link('Sign Out')
  end
end
