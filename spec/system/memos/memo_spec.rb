require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'Create and view memo', type: :system do
  let!(:user) { create :user, :with_setting }

  let(:style_preset) { 'comic-book' }
  let(:image_height) { 1024 }
  let(:image_width) { 1024 }
  let(:png) { file_fixture 'image.png' }
  let(:gen_image_prompt) { 'A doggy dog' }
  let(:generate_text_prompt) { 'This is my prompt' }
  let!(:generate_text_preset) { create :generate_text_preset }
  let(:generative_text) { 'This is AI slop' }
  let(:claude_model) { GenerativeText::Anthropic::MODELS.values.find { _1.api_name == user.setting.text_model } }
  let(:claude_generative_text_response) do
    <<~JSON
      {
        "id": "msg_01DMcCdRr6gaWDuZs7Y63rhe",
        "type": "message",
        "role": "assistant",
        "content": [{
            "type": "text",
            "text": "#{generative_text}"
        }],
        "model": "claude-3-haiku-20240307",
        "stop_reason": "end_turn",
        "stop_sequence": null,
        "usage": {
            "input_tokens": 79,
            "output_tokens": 942
        }
      }
    JSON
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_request(:post, 'https://api.stability.ai/v2beta/stable-image/generate/core')
      .with(headers: {
        'Authorization': "Bearer #{Rails.application.credentials.fetch(:stability_key)}",
        'Accept': 'image/*'
      }).to_return(status: 200, body: png.read, headers: { 'seed' => 1234, 'finish-reason' => 'SUCCESS' })

    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(
        body: {
          model: claude_model.api_name, max_tokens: claude_model.max_tokens,
          temperature: generate_text_preset.temperature,
          messages: [{ 'role' => 'user', 'content' => [{ 'type' => 'text', 'text' => generate_text_prompt }] }],
          system: GenerateTextRequest.new(generate_text_preset:).system_message
        }.to_json
      ).to_return(status: 200, body: claude_generative_text_response)
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'Create memo with generated image' do
    login(user:)
    visit user_memos_path(user)

    click_button 'New Memo'
    fill_in 'Title', with: 'My Memo'

    # Generate image
    click_button('Generate Image')
    find('option[label="3:2"]').select_option
    find('option[label="Comic Book"]').select_option
    find('input#prompt').set gen_image_prompt
    click_button 'Submit'

    # Generated image appears in the editor
    page.driver.wait_for_network_idle
    generate_image_request = user.generate_image_requests.last
    expect(generate_image_request.attributes).to(
      include('options' => { 'style' => style_preset, 'aspect_ratio' => '3:2' },
              'image_name' => a_string_matching(/\Agenimage/))
    )
    figure = find("figure[data-trix-attachment*='#{generate_image_request.image_name}']")
    expect(figure).to be_visible
    expect(figure).to have_css 'img'

    # Wait for direct upload to finish
    page.driver.wait_for_network_idle

    # Save the memo
    click_button 'save'

    expect(page).to have_css '.c-memo'
    expect(page).to have_css 'h1', text: 'My Memo'

    # Verify the blob details are correct
    within("action-text-attachment[filename*='#{generate_image_request.image_name}']") do
      find('.image-info-btn').click
      expect(page).to have_css('.blob-details')

      within('.blob-details') do
        details = generate_image_request.parameterize
        blob = generate_image_request.active_storage_blobs.first

        details[:prompts].each do |prompt|
          expect(page).to have_content prompt.fetch('text')
          expect(page).to have_content "Weight #{prompt.fetch('weight')}"
        end
        expect(page).to have_content "Style #{details.fetch(:style)}"
        expect(page).to have_content "Aspect Ratio #{details.fetch(:aspect_ratio)}"
        expect(page).to have_content "Name #{blob.filename}"

        # Download link
        expect(page).to have_css "a[href='/blobs/#{blob.id}']"
      end
    end

    # Doing this in an after suite hook or after all hook causes the test to
    # fail as if the file is being deleted before the test has completed.
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end

  specify 'create memo with generative text' do
    login(user:)
    visit user_memos_path(user)

    click_button 'New Memo'
    fill_in 'Title', with: 'My Memo'

    click_button 'Generate Text'

    # Select preset that automaticallty sets the temperature option
    find("option[label='#{generate_text_preset.name}']").select_option
    expect(find('select#temperature').value).to eq generate_text_preset.temperature.to_s

    # Generate text autosaves the memo
    find('input[name="generateText"]').set generate_text_prompt
    click_button 'Submit'
    page.driver.wait_for_network_idle
    expect(page).to have_content generative_text
    page.driver.wait_for_network_idle
    memo = user.memos.last
    expect(memo.plain_text_body).to include generative_text

    # A conversation was created which stores both the user prompt and AI response
    page.driver.wait_for_network_idle
    conversation = user.conversations.last
    expect(conversation.memo_id).to eq memo.id
    expect(conversation.exchange.find { |e| e['role'] == 'user' }['content'][0]['text']).to eq generate_text_prompt
    expect(conversation.exchange.find { |e| e['role'] == 'assistant' }['content']).to eq generative_text

    # Conversation ID is set as data attributes
    expect(page).to have_css "form.c-memo-form[data-conversation-id='#{conversation.id}']"
    expect(page).to have_css ".c-wysiwyg-editor[data-conversation-id='#{conversation.id}']"
  end
end
