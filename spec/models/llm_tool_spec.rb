require 'rails_helper'

RSpec.describe LlmTool, type: :model do
  describe '.handler_for' do
    context 'with the GenerateImage' do
      let(:tool_input) do
        {
          'id' => 'toolu_01MdQEyXJfvM5hUpabMKKwMU',
          'name' => 'GenerateImage',
          'type' => 'tool_use',
          'input' => { 'prompt' => 'A sunset over mountains' }
        }
      end

      it 'finds the correct tool and returns an instance of its handler' do
        result = described_class.handler_for(tool_input)
        expect(result).to be_a LlmTool::Handlers::GenerateImage
      end
    end

    context 'with an unknown tool' do
      let(:tool_input) do
        {
          'id' => 'toolu_01MdQEyXJfvM5hUpabMKKwMU',
          'name' => 'ThisToolDoesNotExist',
          'type' => 'tool_use',
          'input' => { 'prompt' => 'A sunset over mountains' }
        }
      end

      it 'raises ActiveRecord::RecordNotFound when tool is not found' do
        expect { described_class.handler_for(tool_input) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#as_json' do
    let(:tool) do
      build_stubbed(:llm_tool, name: 'TestTool', description: 'A test tool', input_schema: { 'type' => 'object', 'properties' => {} })
    end

    it 'returns a hash with the required fields' do
      expected = {
        name: 'TestTool',
        description: 'A test tool',
        input_schema: { 'type' => 'object', 'properties' => {} }
      }
      expect(tool.as_json).to eq(expected)
    end
  end

  describe 'name normalization' do
    it 'normalizes names by removing spaces and camelizing' do
      tool = build(:llm_tool, name: 'test tool name')
      expect(tool.name).to eq('TestToolName')
    end
  end
end
