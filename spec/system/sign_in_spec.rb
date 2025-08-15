require 'system_helper'

RSpec.describe 'signing in', type: :system do
  let(:password) { 'Password' }
  let!(:user) { create :user, :with_setting, password: }

  specify 'user signs in' do
    visit '/'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: password
    click_button 'Log in'
    expect(page).to have_current_path('/')
    expect(page).to have_button('Start New Conversation!')
  end
end
