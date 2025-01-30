require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'create conversation', type: :system do
  let!(:user) { create :user }
  let(:setting) { create :setting, :with_anthropic_text_model, user: }

  let(:style_preset) { 'comic-book' }
  let(:prompt) { 'This is my prompt' }
  let!(:generate_text_preset) { create :generate_text_preset }
  let(:assistant_response) { 'This is the assistant response.' }
  let(:model) { GenerativeText::MODELS.find { _1.api_name == setting.text_model } }
  let(:temperature) { 0.5 }
  let(:generative_text_response) do
    <<~JSON
      {
        "id": "msg_01DMcCdRr6gaWDuZs7Y63rhe",
        "type": "message",
        "role": "assistant",
        "content": [{
            "type": "text",
            "text": "#{assistant_response}"
        }],
        "model": "claude-3-haiku-20240307",
        "stop_reason": "end_turn",
        "stop_sequence": null,
        "usage": {
            "input_tokens": 79,
            "output_tokens": 942,
            "cache_creation_input_tokens": 0,
            "cache_read_input_tokens": 0
        }
      }
    JSON
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(
        body: {
          model: model.api_name, max_tokens: model.max_tokens,
          temperature:,
          messages: [{ 'role' => 'user', 'content' => [{ 'text' => prompt, 'type' => 'text' }] }],
          system: GenerateTextRequest.new(generate_text_preset:).system_message
        }.to_json
      ).to_return(status: 200, body: generative_text_response)
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'create conversation' do
    login(user:)
    visit user_conversations_path(user)

    click_link 'New Conversation'
    expect(page).to have_current_path new_user_conversation_path(user)

    fill_in 'conversation_generate_text_requests_attributes_0_prompt', with: prompt

    find('.options-toggle-btn').click

    within('#advanced-options') do
      find("option[value='#{model.api_name}']").select_option
      find("option[value='#{generate_text_preset.id}']").select_option
      find("option[value='#{temperature}']").select_option
    end

    find('button[type=submit]').click

    conversation = user.conversations.last
    expect(page).to have_current_path edit_user_conversation_path(user, conversation)

    expect(page).to have_css('.segment-user', text: prompt)

    within('.segment-assistant') do
      expect(page).to have_content assistant_response
    end

    # Copy assistant response to clipboard
    find('.copy-btn').click
    copied = page.driver.browser.evaluate_async(%(arguments[0](navigator.clipboard.readText())), 1)
    expect(copied.strip).to eq assistant_response

    # View generate text meta data
    find('button.more-info').click
    expect(page).to have_css('.popover')
    within('.popover') do
      expect(page).to have_content "Model: #{model.name}"
      expect(page).to have_content "Preset: #{generate_text_preset.name}"
      expect(page).to have_content "Temperature: #{temperature}"
      expect(page).to have_content "Tokens: #{79 + 942}"
    end
    find('button.more-info').click

    # Delete conversation turn
    generate_text_request = conversation.generate_text_requests.completed.last
    within('.assistant-response') do
      find('a[data-turbo-method="delete"]').click
    end
    expect(page).not_to have_css "#generate_text_request_#{generate_text_request.id}"
  end
end
