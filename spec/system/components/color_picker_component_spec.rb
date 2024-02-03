require 'system_helper'

RSpec.describe 'ColorPickerComponent', type: :system do
  specify 'selecting colors' do
    visit ColorPickerComponentPreview::DEFAULT_PATH

    expect(page).to have_css('.swatches', visible: :hidden)
    hidden_input = find('input[name="color"]', visible: :hidden)
    expect(hidden_input.value).to be_blank

    find('button.color-picker-opener').click
    expect(page).to have_css('.swatches', visible: :visible)
    expect(page).to have_link('Remove color', visible: :hidden)

    colors = %w[ef6351 1a4301]
    colors.each do |c|
      find("button[id='#{c}']").trigger('click')
      expect(hidden_input.value).to eq c
      expect(page).to have_link('Remove color', visible: :visible)
    end

    click_link 'Remove color'
    expect(hidden_input.value).to be_blank
    expect(page).to have_link('Remove color', visible: :hidden)

    find('button.color-picker-opener').click
    expect(page).to have_css('.swatches', visible: :hidden)
  end
end
