require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'create conversation', type: :system do
  let!(:user) { create :user, :with_setting }

  let(:style_preset) { 'comic-book' }
  let(:prompt) { 'This is my prompt' }
  let!(:generate_text_preset) { create :generate_text_preset }
  let(:assistant_response) { 'This is the assistant response.' }
  let(:claude_model) { GenerativeText::Anthropic::MODELS.values.find { _1.api_name == user.setting.text_model } }
  let(:temperature) { 0.5 }
  let(:claude_generative_text_response) do
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
            "output_tokens": 942
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
          model: claude_model.api_name, max_tokens: claude_model.max_tokens,
          temperature:,
          messages: conversation.exchange
                                .push({ 'role' => 'user', 'content' => [{ 'type' => 'text', 'text' => prompt }] }),
          system: GenerateTextRequest.new(generate_text_preset:).system_message
        }.to_json
      ).to_return(status: 200, body: claude_generative_text_response)
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
    expect(page).to have_current_path edit_user_conversation_path(user, conversation, show_options: true)

    within('#advanced-options') do
      find("option[value='#{claude_model.api_name}']").select_option
      find("option[value='#{generate_text_preset.id}']").select_option
      find("option[value='#{temperature}']").select_option
    end

    find('button[type=submit]').click

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
end
