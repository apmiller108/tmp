require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'generating a conversation title' do
  let(:user) { create :user }
  let!(:setting) { create :setting, :with_anthropic_text_model, user: }

  let(:model) { GenerativeText::MODELS.find { _1.api_name == setting.text_model } }
  let(:conversation) { create :conversation, :with_requests, user:, request_count: 1, tool_types: [] }
  let(:response_body) { file_fixture('anthropic/messages_stream_response.txt').read }
  let(:generate_title_prompt) do
    GenerativeText::Helpers.conversation_title_prompt(conversation)
  end

  let!(:request_stub) do
    stub_anthropic_messages_request(
      prompt: generate_title_prompt, model: GenerativeText::SUMMARY_MODEL, temperature: 0.2,
      tools: nil, tool_choice: nil, markdown_format: nil
    )
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    request_stub
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'generating a conversation title' do
    login(user:)
    navigate_to edit_conversation_path(conversation)
    expect(page).to have_css '.title-field', text: conversation.title

    # Generate a title
    find('#generate-title-btn').click
    expect(page).to have_css('.title-field', text: 'test assistant response')
    expect(request_stub).to have_been_requested
  end
end
