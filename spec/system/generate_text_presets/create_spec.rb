require 'system_helper'

RSpec.describe 'create generate text preset', type: :system do
  let!(:user) { create :user, :with_setting }
  let!(:conversation) { create :conversation, :with_requests, user: }

  specify 'create preset from conversation' do
    login(user:)
    navigate_to edit_conversation_path(conversation)

    # I have no idea why sometimes find().click does not work here.
    # find('.options-toggle-btn').click
    page.execute_script("document.querySelector('.options-toggle-btn').click()")
    within('#advanced-options') do
      click_link 'new_preset_link'
    end

    # Path has the redirect param set
    expect(page).to have_current_path(
      new_generate_text_preset_path(redirect_after_create: edit_conversation_path(conversation))
    )

    # Create new preset
    fill_in 'Name', with: 'Test preset'
    fill_in 'System message', with: 'Test system message'
    fill_in 'Description', with: 'Test description'
    find("option[value='0.5']").select_option
    click_button 'Save Preset'

    preset = user.generate_text_presets.last
    expect(preset.attributes).to include 'name' => 'Test preset',
                                         'system_message' => 'Test system message',
                                         'description' => 'Test description',
                                         'temperature' => 0.5

    # Redirected back to the conversation
    expect(page).to have_current_path edit_conversation_path(conversation, text_preset_id: preset.id)

    # After being redirected the options are still open
    within('#advanced-options') do
      # The new preset is selected by default after redirect
      expect(page).to have_select 'conversation_generate_text_preset_id',
                                  selected: preset.name
      # The presets temperature is automatically selected
      expect(page).to have_field 'conversation_temperature', with: preset.temperature.to_s
    end
  end
end
