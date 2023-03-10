require 'system_helper'

RSpec.describe 'Signing in', type: :system do
  specify 'user signs in' do
    visit '/'
    click_link 'Sign up'
    fill_in 'Email', with: 'alex@example.com'
    fill_in 'Password', with: 'Password!'
    fill_in 'Password confirmation', with: 'Password!'
    click_button 'Sign up'
    expect(page).to have_text I18n.t('devise.registrations.signed_up')
    expect(page).to have_current_path '/'
  end
end
