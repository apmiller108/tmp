require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'update conversation', type: :system do
  let(:user) { create :user, :with_setting }
  let!(:conversations) { create_list(:conversation, 3, :with_requests, user:) }

  before(:context) do
    Sidekiq::Testing.inline!
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'view conversations' do
    login(user:)
    conversation = conversations.first
    navigate_to edit_conversation_path(conversation)

    expect(page).to have_content conversation.title

    within('#conversations') do
      expect(page).to have_css('.list-group-item', count: conversations.size)
    end

    conversation = conversations[1]
    find("#list_conversation_#{conversation.id}").click
    expect(page).to have_content conversation.title

    # delete conversation
    within("#list_conversation_#{conversation.id}") do
      accept_confirm do
        find("#delete_conversation_#{conversation.id}").click
      end
    end
    expect(page).not_to have_content conversation.title
    within('#conversations') do
      expect(page).to have_css('.list-group-item', count: conversations.size - 1)
    end

    conversation = conversations[2]
    find("#list_conversation_#{conversation.id}").click
    expect(page).to have_content conversation.title

    find('#new-conversation').click
    conversation = Conversation.last
    expect(page).to have_current_path edit_conversation_path(conversation)
  end
end
