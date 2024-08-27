require 'system_helper'

RSpec.describe 'Signing up', type: :system do
  let(:email) { Faker::Internet.email }

  specify 'user signs in' do
    visit '/'
    fill_in 'Email', with: email
    fill_in 'Password', with: 'Password!'
    fill_in 'Password confirmation', with: 'Password!'
    click_button 'Sign up'
    expect(page).to have_text I18n.t('devise.registrations.signed_up')
    expect(page).to have_current_path '/'

    user = User.find_by(email:)
    expect(user).to be_present
    expect(user.setting).to be_present
  end
end
