require 'system_helper'

RSpec.describe 'Signing out', type: :system do
  let(:password) { 'Password' }
  let!(:user) { create :user, password: }

  specify 'user logs out' do
    visit new_user_session_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Log in'

    click_button 'Sign Out'
    expect(page).to have_current_path "/"
  end
end
