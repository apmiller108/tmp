require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'search conversations', type: :system do
  let(:user) { create :user }
  let!(:conversation) do
    create :conversation, :with_requests, user:, request_count: 3, embedding: search_term_embedding
  end
  let(:search_term) { 'feline friend' }
  let(:search_term_embedding) { JSON.parse(file_fixture('embeddings/feline_friend.json').read) }

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    create(:setting, user:)
    create_list :conversation, 3, :with_requests, user:, request_count: 1, title: 'should not match'
    stub_voyage_embedding_request(input: [search_term], input_type: :query, embedding: search_term_embedding)
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'search' do
    login(user:)

    visit new_conversation_path

    page.driver.resize(1440, 900)

    # Verify that all four convos are in the list
    within('#conversations') do
      expect(page).to have_css('.list-group-item', count: 4)
    end

    # Use keyboard shortcut to open search
    page.driver.browser.keyboard.type('/')

    expect(page).to have_css '.c-search-modal'

    fill_in 'term', with: search_term
    click_button 'Search'

    within('#conversations') do
      expect(page).to have_css('.list-group-item', count: 1)
      expect(page).to have_css("div#list_conversation_#{conversation.id}")
    end
  end
end
