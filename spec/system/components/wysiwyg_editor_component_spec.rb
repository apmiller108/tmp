require 'system_helper'

RSpec.describe 'WysiwygEditorComponent', type: :system do
  context 'with new object' do
    specify 'using the custom editor buttons' do
      visit(WysiwygEditorComponentPreview::NEW_PATH)
      expect(page).to have_css 'trix-toolbar'

      # Generate text dialog
      click_button('Generate Text')
      expect(page).to have_css '.trix-dialog.trix-custom-generate-text'

      # Try to submit without inputing anything
      click_button 'Submit'
      expect(page).to have_css '.trix-dialog.trix-custom-generate-text'

      # Capybara fill_in/set does not work for dialog input
      page.execute_script("document.querySelector('input.generate-text-input').value = 'foo bar'")
      click_button 'Submit'
      expect(page).not_to have_css '.trix-dialog.trix-custom-generate-text'

      # Heading dialog for creating h1-6 elements
      (1..6).each do |i|
        # Open dialog
        click_button('Heading')
        expect(page).to have_css '.trix-dialog.trix-custom-heading'

        # Add H tag
        heading_button = find("button[data-trix-attribute='heading#{i}']")
        heading_button.click

        # Close dialog
        click_button('Heading')
        expect(page).not_to have_css '.trix-dialog.trix-custom-heading'

        within('trix-editor') do
          expect(page).to have_css "h#{i}"
        end

        # Open dialog, turn remove H tag and close dialog
        click_button('Heading')
        heading_button.click
        click_button('Heading')
      end
    end
  end

  context 'with presisted object' do
    let(:content) { 'Crisis of Infinite Cats' }

    before do
      create :memo, :with_user, content:
    end

    specify 'editing existing content' do
      visit(WysiwygEditorComponentPreview::EDIT_PATH)

      within('trix-editor') do
        expect(page).to have_content content
      end
    end
  end
end
