require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'search conversations', type: :system do
  let(:user) { create :user }
  let!(:conversation) do
    create :conversation, :with_requests, user:, request_count: 3, embedding:
  end
  let(:embedding) { JSON.parse(file_fixture('embeddings/feline_friend.json').read) }

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    create(:setting, user:)
    create_list :conversation, 4, :with_requests, user:, request_count: 1, embedding:
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'viewing related conversations' do
    login(user:)
    navigate_to edit_conversation_path(conversation)

    # shows the top 3 related conversations
    related_convo = nil
    within('.related-conversations') do
      expect(page).to have_css('.conversation-item', count: 3)
      related_convo = page.all('.conversation-item').first
      related_convo.click # Open related conversation
    end

    # View related conversation
    related_convo = Conversation.find(related_convo['data-conversation-id'])
    expect(page).to have_css('#relatedChatModal')
    within('#relatedChatModal') do
      expect(page).to have_content related_convo.title

      related_convo.generate_text_requests.each do |gtr|
        within("#generate_text_request_#{gtr.id}") do
          expect(page).to have_css('.segment-user', text: gtr.prompt_html)

          within('.segment-assistant') do
            expect(page).to have_content gtr.response.content
          end

          # readonly view
          expect(page).not_to have_css('a[data-turbo-method="delete"]')
        end
      end
    end

    click_link 'Go to Conversation'

    expect(page).to have_current_path(edit_conversation_path(related_convo))
  end
end
