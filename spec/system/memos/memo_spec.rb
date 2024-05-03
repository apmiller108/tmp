require 'system_helper'
require 'sidekiq/testing'

RSpec.describe 'Create and view memo', type: :system do
  let!(:user) { create :user }

  let(:style_preset) { 'comic-book' }
  let(:image_height) { 1024 }
  let(:image_width) { 1024 }
  let(:png) { file_fixture 'image.png' }
  let(:gen_image_prompt) { 'A doggy dog' }
  let(:generate_image_response) do
    <<~JSON
      {
        "artifacts": [{
          "base64": "#{Base64.strict_encode64(png.read)}",
          "seed": 3939457358,
          "finishReason": "SUCCESS"
        }]
      }
    JSON
  end

  before(:context) do
    Sidekiq::Testing.inline!
  end

  before do
    stub_request(:post, 'https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image')
      .with(
        body:
          {
            'text_prompts' => [{ 'text' => gen_image_prompt, 'weight' => 3 }],
            'style_preset' => style_preset,
            'height' => image_height,
            'width' => image_width,
            'cfg_scale' => 10,
            'samples' => 1,
            'seed' => 0,
            'steps' => 30
          }.to_json
      ).to_return(status: 200, body: generate_image_response, headers: {})
  end

  after(:context) do
    Sidekiq::Testing.fake!
  end

  specify 'Create memo with generated image' do
    login(user:)
    visit user_memos_path(user)

    click_button 'New Memo'
    fill_in 'Title', with: 'My Memo'

    # Generate image
    click_button('Generate Image')
    find('option[label="1024x1024"]').select_option
    find('option[label="Comic Book"]').select_option
    select '3', from: 'weight'
    page.execute_script("document.querySelector(\"input#prompt\").value = '#{gen_image_prompt}'")
    click_button 'Submit'

    # Generated image appears in the editor
    page.driver.wait_for_network_idle
    generate_image_request = user.generate_image_requests.last
    expect(generate_image_request.attributes).to include('style' => style_preset,
                                                         'dimensions' => "#{image_width}x#{image_height}",
                                                         'image_name' => a_string_matching(/\Agenimage/))
    figure = find("figure[data-trix-attachment*='#{generate_image_request.image_name}']")
    expect(figure).to be_visible
    expect(figure).to have_css 'img'

    # Wait for direct upload to finish
    page.driver.wait_for_network_idle

    # Save the memo
    click_button 'save'

    expect(page).to have_css '.c-memo'
    expect(page).to have_css 'h1', text: 'My Memo'

    # Verify the blob details are correct
    within("action-text-attachment[filename*='#{generate_image_request.image_name}']") do
      find('.image-info-btn').click
      expect(page).to have_css('.blob-details')

      within('.blob-details') do
        details = generate_image_request.parameterize
        blob = generate_image_request.active_storage_blobs.first

        details[:prompts].each do |prompt|
          expect(page).to have_content prompt.fetch('text')
          expect(page).to have_content "Weight #{prompt.fetch('weight')}"
        end
        expect(page).to have_content "Style #{details.fetch(:style)}"
        expect(page).to have_content "Dimensions #{details.fetch(:dimensions)}"
        expect(page).to have_content "Name #{blob.filename}"

        # Download link
        expect(page).to have_css "a[href='/blobs/#{blob.id}']"
      end
    end

    # Doing this in an after suite hook or after all hook causes the test to
    # fail as if the file is being deleted before the test has completed.
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
