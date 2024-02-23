require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'WysiwygEditorComponent', type: :system do
  let(:user) { create :user }
  let(:prompt) { 'This is my prompt' }
  let(:generative_text) { 'this is the generated text' }
  let(:generative_text_response) do
    <<~JSON
      {
        "inputTextTokenCount": 5,
        "results": [
          {
            "tokenCount": 55,
            "outputText": "#{generative_text}",
            "completionReason": "FINISH"
          }
        ]
      }
    JSON
  end

  before do
    Sidekiq::Testing.inline!
    stub_request(:post, 'https://bedrock-runtime.us-east-1.amazonaws.com/model/amazon.titan-text-express-v1/invoke')
      .with(body: {
        inputText: prompt, textGenerationConfig: { maxTokenCount: 500, stopSequences: [], temperature: 0.3, topP: 0.8 }
      }.to_json)
      .to_return(status: 200, body: generative_text_response)
  end

  after do
    Sidekiq::Testing.fake!
  end

  context 'with new object' do
    specify 'using the custom editor buttons' do
      login(user:)
      visit(WysiwygEditorComponentPreview::NEW_PATH)

      expect(page).to have_css 'trix-toolbar'
      expect(page).to have_css 'trix-editor'

      # Generate text dialog
      click_button('Generate Text')
      expect(page).to have_css '.trix-dialog.trix-custom-generate-text'

      # Try to generate text without inputing anything
      click_button 'Submit'
      expect(page).to have_css '.trix-dialog.trix-custom-generate-text'

      # Generate text successfully
      # Capybara fill_in/set does not work for dialog input
      page.execute_script("document.querySelector(\"input.generate-content-input[type='text']\").value = '#{prompt}'")
      click_button 'Submit'
      expect(page).not_to have_css '.trix-dialog.trix-custom-generate-text'
      expect(page).to have_content generative_text

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
