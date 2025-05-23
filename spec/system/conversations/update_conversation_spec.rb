require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'update conversation', type: :system do
  let(:user) { create :user }
  let!(:setting) { create :setting, :with_anthropic_text_model, user: }

  let(:prompt) { 'This is my prompt' }
  let!(:generate_text_preset) { create :generate_text_preset }
  let(:assistant_response) { 'test assistant response' }
  let(:model) { GenerativeText::MODELS.find { _1.api_name == setting.text_model } }
  let(:temperature) { 0.5 }
  let(:conversation) { create :conversation, :with_requests, user:, request_count: 3, tool_types: ['image'] }
  let(:response_body) { file_fixture('anthropic/messages_stream_response.txt').read }
  let(:embedding_request_stub) do
    stub_voyage_embedding_request(input: [[conversation.blobify, prompt, assistant_response].join(' ')])
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_anthropic_stream_request(
      prompt:, temperature:, generate_text_preset:, model:,
      messages: conversation.exchange, assistant_response:, response_body:
    )
    embedding_request_stub
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'update conversation' do
    login(user:)
    navigate_to edit_conversation_path(conversation)

    expect(page).to have_css('.c-conversation-turn', count: 3)

    conversation.generate_text_requests.each do |gtr|
      within("#generate_text_request_#{gtr.id}") do
        expect(page).to have_css('.segment-user', text: gtr.prompt_html)

        within('.segment-assistant') do
          expect(page).to have_content gtr.response.content
        end
      end
    end

    fill_in 'conversation_prompt', with: prompt

    # I have no idea why sometimes on some specs, find().click does not work
    # here. find('.options-toggle-btn').click
    page.execute_script("document.querySelector('.options-toggle-btn').click()")
    within('#advanced-options') do
      find("option[value='#{model.api_name}']").select_option
      find("option[value='#{generate_text_preset.id}']").select_option
      find('#conversation_temperature').set(temperature)
    end

    page.driver.clear_network_traffic
    within('.c-prompt-form') do
      find('button[type=submit]').click
    end
    page.driver.wait_for_network_idle

    expect(page).to have_css('.c-conversation-turn', count: 4)

    within('.c-prompt-form') do
      expect(find('button[type="submit"]')).not_to be_disabled
    end

    # The controller updates the conversation turn component in render, and the
    # background job that generates the text broadcasts the conversation turn
    # component. When running the sidekiq inline, the render action overwrites
    # the broadcasted component. Reloading the page as a workaround.
    navigate_to edit_conversation_path(conversation)

    generate_text_request = conversation.generate_text_requests.completed.last
    within("#generate_text_request_#{generate_text_request.id}") do
      expect(page).to have_css('.segment-user', text: prompt)

      within('.segment-assistant') do
        expect(page).to have_content assistant_response
      end
    end

    expect(embedding_request_stub).to have_been_requested
  end

  context 'with the default options' do
    let(:last_request) { conversation.generate_text_requests.last }
    let(:temperature) { last_request.temperature }
    let(:model) { last_request.model }
    let(:generate_text_preset) { last_request.generate_text_preset }

    before do
      stub_anthropic_stream_request(
        prompt:, temperature:, generate_text_preset:, model:, messages: conversation.exchange, assistant_response:
      )
    end

    it 'sets the default options to the options used in the last request' do
      login(user:)
      navigate_to edit_conversation_path(conversation)

      fill_in 'conversation_prompt', with: prompt

      within('.c-prompt-form') do
        find('button[type=submit]').click
      end

      expect(page).to have_css('.c-conversation-turn', count: 4)
    end
  end
end
