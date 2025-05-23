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
  let(:tool_use_response) do
    { 'options' => { 'style' => 'fantasy-art', 'aspect_ratio' => '16:9', 'request_type' => 'text_to_image' },
      'prompts' => { 'prompt' => 'image prompt', 'negative_prompt' => 'negative prompt' } }
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_anthropic_stream_request(
      prompt:, temperature:, generate_text_preset:, model:,
      messages: conversation.exchange, assistant_response:, response_body:
    )
    stub_voyage_embedding_request(input: [[conversation.blobify, prompt, assistant_response,
                                           tool_use_response.to_s].join(' ')])
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  shared_examples 'LLM uses generative image AI and shows the results' do
    specify 'generating an image and viewing the results' do
      login(user:)
      navigate_to edit_conversation_path(conversation)
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

      # Configure converation settings
      within('.c-prompt-form') do
        find('button.settings-btn').click
        within('#convoSettingsModal') do
          # Enable image tools
          find('#conversation_tool_type_image').click
          find('button.btn-close').click
        end
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

  context 'with a text_to_image generate_image tool response' do
    let(:response_body) { file_fixture('anthropic/tool_use_stream_text_to_image_response.txt').read }

    before do
      stub_stability_core_request
    end

    it_behaves_like 'LLM uses generative image AI and shows the results'
  end

  # Vips error after getting a variant of an uploaded image. It appears like the
  # file is not where it should be
  #
  # context 'with an image_to_image generate_image tool response' do
  #   let(:response_body) { file_fixture('anthropic/tool_use_stream_image_to_image_response.txt').read }

  #   before do
  #     stub_stability_ultra_request
  #   end

  #   specify 'generating an image and viewing the results' do
  #     login(user:)
  #     visit edit_conversation_path(conversation)
  #     # Fill out and submit the form
  #     fill_in 'conversation_prompt', with: prompt

  #     # I have no idea why sometimes find().click does not work here.
  #     page.execute_script("document.querySelector('.options-toggle-btn').click()")
  #     # find('.options-toggle-btn').click
  #     within('#advanced-options') do
  #       find("option[value='#{model.api_name}']").select_option
  #       find("option[value='#{generate_text_preset.id}']").select_option
  #       find('#conversation_temperature').set(temperature)
  #     end

  #     file_input = find('#conversation_file')
  #     file_path = file_fixture('image.png')
  #     file_input.attach_file(file_path)

  #     page.driver.clear_network_traffic
  #     within('.c-prompt-form') do
  #       find('button[type=submit]').click
  #     end
  #     page.driver.wait_for_network_idle(timeout: 15)

  #     # The controller updates the conversation turn component in render, and the
  #     # background job that generates the text broadcasts the conversation turn
  #     # component. When running the sidekiq inline, the render action overwrites
  #     # the broadcasted component. Reloading the page as a workaround.
  #     visit edit_conversation_path(conversation)

  #     expect(page).to have_css('.c-generate-text-request', count: 4)

  #     # Tool use generate_image response creates generate image request turn
  #     expect(page).to have_css('.c-generate-image-request', count: 1)

  #     image_request = conversation.generate_image_requests.last
  #     within '.c-generate-image-request' do
  #       # view more info
  #       find('.btn.more-info').click

  #       within '.blob-details' do
  #         image_request.prompts.each do |p|
  #           expect(page).to have_content p.text
  #         end
  #         expect(page).to have_content image_request.style.sub(/-/, ' ').capitalize
  #         expect(page).to have_content image_request.request_type.humanize.capitalize
  #         expect(page).to have_content image_request.quality.capitalize
  #         expect(page).to have_content image_request.aspect_ratio
  #         expect(page).to have_content image_request.image.blob.filename
  #       end
  #     end
  #   end
  # end
end
