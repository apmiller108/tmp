require 'system_helper'

RSpec.describe 'ClipboardComponent', type: :system do
  specify 'copying text to the clipboard' do
    visit ClipboardComponentPreview::DEFAULT_PATH

    expect(page).to have_css 'i.bi-copy', visible: true
    expect(page).to have_css 'i.bi-check2-square', visible: false

    fill_in 'copyable', with: 'asdf'
    find('.copy-btn').click

    expect(page).to have_css 'i.bi-copy', visible: false
    expect(page).to have_css 'i.bi-check2-square', visible: true
  end
end
