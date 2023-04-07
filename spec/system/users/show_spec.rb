require 'system_helper'

RSpec.describe 'User show', type: :system do
  let!(:user) { create :user }

  specify 'user views their details' do
    login(user:)
    visit user_path(user)
    expect(page).to have_text(user.email)
  end
end
