require 'rails_helper'

RSpec.describe Gemini::InvokeModelRequest do
  let(:model) { GenerativeText::MODELS.find { |m| m.api_name == 'gemini-2.5-flash' } }
  let(:generate_text_request) { create :generate_text_request, model: model.api_name, prompt: 'Hello' }
  subject { described_class.new(generate_text_request) }

  describe '#to_h' do
    it 'returns the correct structure' do
      json = subject.to_h
      expect(json[:contents]).to be_a(Array)
      expect(json[:contents].first[:parts].first[:text]).to eq('Hello')
      expect(json[:generationConfig][:temperature]).to eq(generate_text_request.temperature)
    end

    context 'with system instructions' do
      let(:generate_text_preset) { create :generate_text_preset, system_message: 'Be helpful' }
      let(:generate_text_request) do
        create :generate_text_request, model: model.api_name, generate_text_preset: generate_text_preset
      end

      it 'includes systemInstruction' do
        json = subject.to_h
        expect(json[:systemInstruction][:parts].first[:text]).to include('Be helpful')
      end
    end

    context 'with tools' do
      let(:tool) do
        create :llm_tool,
               name: 'weather_tool',
               description: 'Get weather',
               tool_type: 'image',
               input_schema: { type: 'object', properties: {} }.to_json
      end
      let(:conversation) { create :conversation, tool_types: ['image'] }
      let(:generate_text_request) do
        create :generate_text_request, model: model.api_name, conversation: conversation
      end

      before do
        allow(LlmTool).to receive(:active).and_return(LlmTool.where(id: tool.id))
      end

      it 'includes tools' do
        json = subject.to_h
        expect(json[:tools]).to be_a(Array)
        expect(json[:tools].first[:function_declarations]).to be_a(Array)
        expect(json[:tools].first[:function_declarations].first[:name]).to eq('WeatherTool')
      end
    end
  end
end
