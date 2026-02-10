require 'rails_helper'

RSpec.describe GenerateTextJob, type: :job do
  include GeminiHelpers

  let(:user) { create :user }
  let(:model) { GenerativeText::MODELS.find { |m| m.vendor == :google } }
  let(:conversation) { create :conversation, user: user }
  let(:generate_text_request) do
     create :generate_text_request, user: user, model: model.api_name, prompt: 'Hello Gemini', conversation: conversation
  end
  
  describe '#perform' do
    context 'with a Gemini model' do
      before do
        allow(ENV).to receive(:fetch).with('GEMINI_API_KEY').and_return('fake_key')
        
        stub_gemini_generate_content_request(
          model: model,
          response_body: {
            candidates: [
              {
                content: {
                  parts: [{ text: 'Hello from Gemini' }]
                }
              }
            ],
            usageMetadata: { promptTokenCount: 5, candidatesTokenCount: 5 }
          }.to_json
        )
      end

      it 'completes the request and saves the response' do
        described_class.new.perform(generate_text_request.id, false)
        
        generate_text_request.reload
        expect(generate_text_request.status).to eq('completed')
        expect(generate_text_request.response.content).to eq('Hello from Gemini')
        expect(generate_text_request.response.data).to be_present
      end
    end
  end
end