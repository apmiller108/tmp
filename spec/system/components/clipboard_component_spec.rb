require 'system_helper'

RSpec.describe 'ClipboardComponent', type: :system do
  specify 'copying text to the clipboard' do
    visit ClipboardComponentPreview::DEFAULT_PATH

    expect(page).to have_css 'i.bi-copy', visible: true
    expect(page).to have_css 'i.bi-check2-square', visible: false

    input = 'asdf'
    fill_in 'copyable', with: input
    find('.copy-btn').click

    expect(page).to have_css 'i.bi-copy', visible: false
    expect(page).to have_css 'i.bi-check2-square', visible: true

    # See also https://github.com/rubycdp/ferrum?tab=readme-ov-file#evaluate_asyncexpression-wait_time-args
    text = page.driver.browser.evaluate_async(%(arguments[0](navigator.clipboard.readText())), 1)
    expect(text).to eq input
  end
end
