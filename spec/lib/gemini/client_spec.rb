require 'rails_helper'

RSpec.describe Gemini::Client do
  let(:client) { described_class.new }
  let(:prompt) { 'Write a haiku about a rainy day.' }
  let(:model) { GenerativeText::MODELS.find { |m| m.api_name == 'gemini-1.5-flash-latest' } }
  let(:temperature) { 0.1 }
  let(:generate_text_request) { create :generate_text_request, model: model.api_name, prompt:, temperature: }

  before do
    allow(ENV).to receive(:fetch).with('GEMINI_API_KEY').and_return('fake_key')
  end

  describe '#invoke_model' do
    context 'with a valid request' do
      let!(:http_request) do
        stub_gemini_generate_content_request(model: model)
      end

      it 'calls the generateContent endpoint' do
        client.invoke_model(generate_text_request)
        expect(http_request).to have_been_requested
      end

      it 'returns an InvokeModelResponse object' do
        response = client.invoke_model(generate_text_request)
        expect(response).to be_a(Gemini::InvokeModelResponse)
      end
    end

    context 'with an error response' do
      before do
        stub_gemini_generate_content_request(model: model, response_status: 400, response_body: 'Bad Request')
      end

      it 'raises an error' do
        expect { client.invoke_model(generate_text_request) }
          .to raise_error(Gemini::ClientError, /Gemini API Error: 400/)
      end
    end
  end

  describe '#invoke_model_stream' do
    context 'with a valid request' do
      let!(:http_request) do
        stub_gemini_stream_generate_content_request(
          model: model, 
          response_body: file_fixture('gemini/stream_response.txt').read
        )
      end

      it 'yields text content from stream events' do
        chunks = []
        client.invoke_model_stream(generate_text_request) { |chunk| chunks << chunk }
        expect(chunks).to eq(['Hello', ' World'])
      end

      it 'returns an InvokeModelResponse object' do
        response = client.invoke_model_stream(generate_text_request) {}
        expect(response).to be_a(Gemini::InvokeModelResponse)
      end
    end

    context 'with an error response' do
      before do
        stub_gemini_stream_generate_content_request(model: model, response_status: 400, response_body: 'Bad Request')
      end

      it 'raises an error' do
        expect { client.invoke_model_stream(generate_text_request) {} }
          .to raise_error(Gemini::ClientError, /Gemini API Error: 400/)
      end
    end
  end
end
