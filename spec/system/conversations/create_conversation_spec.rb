require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'create conversation', type: :system do
  let!(:user) { create :user }
  let(:setting) { create :setting, :with_anthropic_text_model, user: }

  let(:prompt) { 'This is my prompt' }
  let!(:generate_text_preset) { create :generate_text_preset }
  let(:assistant_response) { 'test assistant response' }
  let(:model) { GenerativeText::MODELS.find { _1.api_name == setting.text_model } }
  let(:temperature) { 0.5 }
  let(:embedding_request_stub) do
    stub_voyage_embedding_request(input: ['This is my prompt This is my prompt test assistant response'])
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_anthropic_stream_request(
      model:, assistant_response:, temperature:, generate_text_preset:, prompt:
    )
    embedding_request_stub
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'create conversation' do
    login(user:)
    navigate_to new_conversation_path

    fill_in 'conversation_prompt', with: prompt

    # I have no idea why sometimes on some specs, find().click does not work
    # here. find('.options-toggle-btn').click
    page.execute_script("document.querySelector('.options-toggle-btn').click()")

    within('#advanced-options') do
      find("option[value='#{model.api_name}']").select_option
      find("option[value='#{generate_text_preset.id}']").select_option
      find('#conversation_temperature').set(temperature)
    end

    find('button.settings-btn').click
    within('#convo-settings-modal') do
      # Enable image tools
      find('#conversation_tool_type_image').click
      find('button.btn-close').click
    end

    find('button[type=submit]').click

    retries = 0
    conversation = nil
    while conversation.nil? && retries < 3
      conversation = user.conversations.last
      retries += 1
    end

    expect(page).to have_current_path edit_conversation_path(conversation)

    expect(page).to have_css('.segment-user', text: prompt)

    within('.segment-assistant') do
      expect(page).to have_content assistant_response
    end

    expect(embedding_request_stub).to have_been_requested

    # Copy assistant response to clipboard
    within('.assistant-response') do
      find('.copy-btn').click
      copied = page.driver.browser.evaluate_async(%(arguments[0](navigator.clipboard.readText())), 1)
      expect(copied.strip).to eq assistant_response
    end

    # View generate text meta data
    find('a.more-info').click
    expect(page).to have_css('.popover')
    within('.popover') do
      expect(page).to have_content "Model: #{model.name}"
      expect(page).to have_content "Preset: #{generate_text_preset.name}"
      expect(page).to have_content "Temperature: #{temperature}"
      expect(page).to have_content "Tokens: #{25 + 15}" # see fixtures/anthropic/message_stream_response.txt
    end
    find('a.more-info').click

    # Delete conversation turn
    generate_text_request = conversation.generate_text_requests.completed.last
    within('.assistant-response') do
      accept_prompt do
        find('a[data-turbo-method="delete"]').click
      end
    end
    expect(page).not_to have_css "#generate_text_request_#{generate_text_request.id}"

    page.execute_script('localStorage.clear()')
  end
end
