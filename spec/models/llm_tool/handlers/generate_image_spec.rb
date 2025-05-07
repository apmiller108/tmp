require 'rails_helper'

RSpec.describe LlmTool::Handlers::GenerateImage do
  subject(:handler) { described_class.new(input) }

  let(:input) do
    {
      'options' => { 'style' => 'fantasy-art', 'aspect_ratio' => '16:9' },
      'prompts' => { 'prompt' => 'image prompt', 'negative_prompt' => 'negative prompt' }
    }
  end

  let(:user) { create(:user, :with_setting) }
  let(:conversation) { create(:conversation, user:) }
  let(:generate_text_request) do
    create(:generate_text_request, :with_tool_use_response, user:, conversation:)
  end

  before do
    allow(Conversations::GenerateImageJob).to receive(:perform_async)
    allow(GenerateImageRequestForm).to receive(:new).and_call_original
  end

  it 'instantiates the form with the proper attributes' do
    handler.call(generate_text_request)
    expect(GenerateImageRequestForm).to(
      have_received(:new).with(
        {
          'user' => user,
          'conversation' => conversation,
          'generate_text_request' => generate_text_request,
          'aspect_ratio' => '16:9',
          'prompt' => 'image prompt',
          'negative_prompt' => 'negative prompt',
          'style' => 'fantasy-art'
        }
      )
    )
  end

  context 'when form submission succeeds' do
    it 'creates a generate image request' do
      expect { handler.call(generate_text_request) }.to change(conversation.generate_image_requests, :count).by(1)
    end

    it 'enqueues generate image job' do
      handler.call(generate_text_request)
      expect(Conversations::GenerateImageJob).to have_received(:perform_async)
    end

    it 'returns true' do
      expect(handler.call(generate_text_request)).to be true
    end
  end
end
