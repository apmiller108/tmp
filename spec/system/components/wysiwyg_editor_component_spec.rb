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

  let(:png) { file_fixture 'image.png' }
  let(:generate_image_response) do
    <<~JSON
      {
        "artifacts": [{
          "base64": "#{Base64.strict_encode64(png.read)}",
          "seed": 3939457358,
          "finishReason": "SUCCESS"
        }]
      }
    JSON
  end

  before do
    Sidekiq::Testing.inline!

    stub_request(:post, 'https://bedrock-runtime.us-east-1.amazonaws.com/model/amazon.titan-text-express-v1/invoke')
      .with(body: {
        inputText: prompt, textGenerationConfig: {
          maxTokenCount: 500, stopSequences: [], temperature: 0.3, topP: 0.8
        }
      }.to_json)
      .to_return(status: 200, body: generative_text_response)

    stub_request(:post, 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image')
      .with(
        body:
          {
            'text_prompts' => [{ 'text' => prompt, 'weight' => 3 }],
            'style_preset' => 'comic-book',
            'height' => 1024,
            'width' => 1024,
            'cfg_scale' => 10,
            'samples' => 1,
            'seed' => 0,
            'steps' => 30
          }.to_json
      ).to_return(status: 200, body: generate_image_response, headers: {})
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

      # Generate image
      click_button('Generate Image')
      expect(page).to have_css '.trix-dialog.trix-custom-generate-image'

      # Try to generate image without inputing anything
      click_button 'Submit'
      expect(page).to have_css '.trix-dialog.trix-custom-generate-image'

      # Generate an image
      find('option[label="1024x1024"]').select_option
      find('option[label="Comic Book"]').select_option
      select '3', from: 'weight'
      page.execute_script("document.querySelector(\"input#prompt\").value = '#{prompt}'")
      click_button 'Submit'
      expect(page).not_to have_css '.trix-dialog.trix-custom-generate-image'
      generate_image_request = user.generate_image_requests.last
      expect(generate_image_request.attributes).to include('style' => 'comic-book',
                                                           'dimensions' => '1024x1024',
                                                           'image_name' => a_string_matching(/\Agenimage/))
      figure = find("figure[data-trix-attachment*='#{generate_image_request.image_name}']")
      expect(figure).to be_visible
      expect(figure).to have_css 'img'

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
