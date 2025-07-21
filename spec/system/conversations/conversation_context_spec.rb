require 'system_helper'

RSpec.describe 'Conversation Contexts', type: :system do
  let(:user) { create(:user) }
  let!(:conversation) { create(:conversation, user:) }
  let(:file_response) do
    instance_double(Anthropic::FileResponse, id: 'file_id', filename: 'test.pdf', mime_type: 'application/pdf')
  end

  before do
    allow(Anthropic).to receive(:upload_file).and_return(file_response)
    create(:setting, :with_anthropic_text_model, user:)
    login(user:)
    navigate_to edit_conversation_path(conversation)
  end

  context 'when uploading a new file' do
    it 'adds the file to the conversation context' do
      find('button.context-btn').click

      within('#convo-context-modal') do
        sleep 1 # allow time for lazy loading turbo frame to finish
        attach_file_to_input(input_id: 'conversation-context-file-input')
        expect(page).to have_css('.context-item', count: 1)
      end
    end
  end

  context 'when adding an existing file' do
    let!(:conversation_context) { create(:conversation_context, user:) }

    it 'adds the existing file to the conversation context' do
      find('button.context-btn').click

      within('#convo-context-modal') do
        select conversation_context.filename, from: 'conversation_context_conversation_context_ids'
        click_button 'Add Selected Files'

        expect(page).to have_css('.context-item', count: 1)
      end
    end
  end

  context 'when removing a file' do
    let!(:conversation_context) { create(:conversation_context, user:) }
    let!(:conversation_contexts_conversation) do
      create(:conversation_contexts_conversation, conversation:, context: conversation_context)
    end

    it 'removes the file from the conversation context' do
      find('button.context-btn').click

      within('#convo-context-modal') do
        find("#delete_conversation_contexts_conversation_#{conversation_contexts_conversation.id}").click
        expect(page).not_to have_css('.context-item')
      end
    end
  end
end
