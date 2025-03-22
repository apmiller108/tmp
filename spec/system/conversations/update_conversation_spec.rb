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
  let(:conversation) { create :conversation, :with_requests, user:, request_count: 3 }
  let(:tool_use?) { false }

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_anthropic_stream_request(
      prompt:, temperature:, generate_text_preset:, model:,
      messages: conversation.exchange, assistant_response:, tool_use?: tool_use?
    )
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'update conversation' do
    login(user:)
    visit edit_conversation_path(conversation)

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

    find('.options-toggle-btn').click
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
    visit edit_conversation_path(conversation)

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
      visit edit_conversation_path(conversation)

      fill_in 'conversation_prompt', with: prompt

      within('.c-prompt-form') do
        find('button[type=submit]').click
      end

      expect(page).to have_css('.c-conversation-turn', count: 4)
    end
  end

  context 'with a generate_image tool response' do
    let(:tool_use?) { true }

    before do
      stub_stability_core_request
    end

    it 'shows the assistance response and the generated image' do
      login(user:)
      visit edit_conversation_path(conversation)

      # Fill out and submit the form
      fill_in 'conversation_prompt', with: prompt

      # I have no idea why sometimes find().click does not work here.
      page.execute_script("document.querySelector('.options-toggle-btn').click()")
      # find('.options-toggle-btn').click
      within('#advanced-options') do
        find("option[value='#{model.api_name}']").select_option
        find("option[value='#{generate_text_preset.id}']").select_option
        find('#conversation_temperature').set(temperature)
      end

      page.driver.clear_network_traffic
      within('.c-prompt-form') do
        find('button[type=submit]').click
      end
      page.driver.wait_for_network_idle(timeout: 15)

      # The controller updates the conversation turn component in render, and the
      # background job that generates the text broadcasts the conversation turn
      # component. When running the sidekiq inline, the render action overwrites
      # the broadcasted component. Reloading the page as a workaround.
      visit edit_conversation_path(conversation)

      expect(page).to have_css('.c-generate-text-request', count: 4)

      # Tool use generate_image response creates generate image request turn
      expect(page).to have_css('.c-generate-image-request', count: 1)

      image_request = conversation.generate_image_requests.last
      within '.c-generate-image-request' do
        # view more info
        find('.btn.more-info').click

        within '.blob-details' do
          image_request.prompts.each do |p|
            expect(page).to have_content p.text
          end
          expect(page).to have_content image_request.style.sub(/-/, ' ').capitalize
          expect(page).to have_content image_request.request_type.humanize.capitalize
          expect(page).to have_content image_request.quality.capitalize
          expect(page).to have_content image_request.aspect_ratio
          expect(page).to have_content image_request.image.blob.filename
        end
      end
    end
  end
end
