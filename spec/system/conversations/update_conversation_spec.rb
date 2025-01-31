require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'update conversation', type: :system do
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
  let(:conversation) { create :conversation, :with_requests, user:, request_count: 3 }

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_request(:post, 'https://api.anthropic.com/v1/messages')
      .with(
        body: {
          model: model.api_name, max_tokens: model.max_tokens,
          temperature:,
          messages: conversation.exchange
                                .push({ 'role' => 'user', 'content' => [{ 'text' => prompt, 'type' => 'text' }] }),
          system: GenerateTextRequest.new(generate_text_preset:).system_message
        }.to_json
      ).to_return(status: 200, body: generative_text_response)
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'update conversation' do
    login(user:)
    visit edit_user_conversation_path(user, conversation)

    expect(page).to have_css('.c-conversation-turn', count: 3)

    conversation.generate_text_requests.each do |gtr|
      within("#generate_text_request_#{gtr.id}") do
        expect(page).to have_css('.segment-user', text: gtr.prompt)

        within('.segment-assistant') do
          expect(page).to have_content gtr.response.content
        end
      end
    end

    fill_in 'conversation_generate_text_requests_attributes_0_prompt', with: prompt

    find('.options-toggle-btn').click
    expect(page).to have_current_path edit_user_conversation_path(user, conversation)

    within('#advanced-options') do
      find("option[value='#{model.api_name}']").select_option
      find("option[value='#{generate_text_preset.id}']").select_option
      find("option[value='#{temperature}']").select_option
    end

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
    visit edit_user_conversation_path(user, conversation)

    generate_text_request = conversation.generate_text_requests.completed.last
    within("#generate_text_request_#{generate_text_request.id}") do
      expect(page).to have_css('.segment-user', text: prompt)

      within('.segment-assistant') do
        expect(page).to have_content assistant_response
      end
    end
  end

  context 'with the default options' do
    let(:last_request) { conversation.generate_text_requests.last }

    before do
      stub_request(:post, 'https://api.anthropic.com/v1/messages')
        .with(
          body: {
            model: last_request.model.api_name, max_tokens: last_request.model.max_tokens,
            temperature: last_request.temperature,
            messages: conversation.exchange
                                  .push({ 'role' => 'user',
                                          'content' => [
                                            { 'text' => prompt, 'type' => 'text' }
                                          ] }),
            system: GenerativeText::Helpers.markdown_sys_msg
          }.to_json
        ).to_return(status: 200, body: generative_text_response)
    end

    it 'sets the default options to the options used in the last request' do
      login(user:)
      visit edit_user_conversation_path(user, conversation)

      fill_in 'conversation_generate_text_requests_attributes_0_prompt', with: prompt

      within('.c-prompt-form') do
        find('button[type=submit]').click
      end

      expect(page).to have_css('.c-conversation-turn', count: 4)
    end
  end
end
