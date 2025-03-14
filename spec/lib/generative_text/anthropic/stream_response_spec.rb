require 'rails_helper'

RSpec.describe GenerativeText::Anthropic::StreamResponse do
  subject(:stream_response) { described_class.new }

  let(:message_start_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'message_start',
      data: {
        'message' => {
          'id' => 'msg_123',
          'type' => 'message',
          'role' => 'assistant',
          'content' => [],
          'model' => 'claude-3-haiku-20240307',
          'usage' => { 'input_tokens' => 10, 'output_tokens' => 0 }
        }
      },
      message: {
        'id' => 'msg_123',
        'type' => 'message',
        'role' => 'assistant',
        'content' => [],
        'model' => 'claude-3-haiku-20240307',
        'usage' => { 'input_tokens' => 10, 'output_tokens' => 0 }
      }
    )
  end

  let(:text_block_start_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'content_block_start',
      index: 0,
      content_block_type: 'text',
      data: {
        'index' => 0,
        'content_block' => {
          'type' => 'text',
          'text' => ''
        }
      },
      content_block: { 'type' => 'text', 'text' => '' }
    )
  end

  let(:text_delta_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'content_block_delta',
      index: 0,
      delta_type: 'text_delta',
      delta_text: 'Hello',
      data: {
        'index' => 0,
        'delta' => {
          'type' => 'text_delta',
          'text' => 'Hello'
        }
      }
    )
  end

  let(:text_block_stop_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'content_block_stop',
      index: 0,
      data: {
        'index' => 0
      }
    )
  end

  let(:tool_use_start_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'content_block_start',
      index: 1,
      content_block_type: 'tool_use',
      data: {
        'index' => 1,
        'content_block' => {
          'type' => 'tool_use',
          'id' => 'toolu_123',
          'name' => 'get_weather',
          'input' => {}
        }
      },
      content_block: {
        'type' => 'tool_use',
        'id' => 'toolu_123',
        'name' => 'get_weather',
        'input' => {}
      }
    )
  end

  let(:tool_use_delta_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'content_block_delta',
      index: 1,
      delta_type: 'input_json_delta',
      delta_partial_json: '{"location": "Goodlettsville"}',
      data: {
        'index' => 1,
        'delta' => {
          'type' => 'input_json_delta',
          'partial_json' => '{"location": "Goodlettsville"}'
        }
      }
    )
  end

  let(:tool_use_stop_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'content_block_stop',
      index: 1,
      data: {
        'index' => 1
      }
    )
  end

  let(:message_delta_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'message_delta',
      data: {
        'delta' => {
          'stop_reason' => 'end_turn',
          'stop_sequence' => nil
        }
      },
      usage: {
        'output_tokens' => 20
      }
    )
  end

  let(:message_stop_event) do
    instance_double(
      GenerativeText::Anthropic::StreamEvent,
      type: 'message_stop',
      data: {
        'type' => 'message_stop'
      }
    )
  end

  describe '#initialize' do
    it 'initializes with empty message' do
      expect(stream_response.message).to eq({})
    end

    it 'initializes with empty content blocks' do
      expect(stream_response.content_blocks).to eq([])
    end

    it 'initializes with complete set to false' do
      expect(stream_response.complete).to be false
    end
  end

  describe '#update' do
    context 'with message_start event' do
      it 'sets the message' do
        stream_response.update(message_start_event)
        expect(stream_response.message).to eq message_start_event.data['message']
      end
    end

    context 'with content_block_start event for text' do
      it 'adds a text content block' do
        stream_response.update(text_block_start_event)
        expect(stream_response.content_blocks[0]).to eq text_block_start_event.data['content_block']
      end
    end

    context 'with content_block_delta event for text' do
      before do
        stream_response.update(text_block_start_event)
      end

      it 'appends text to the content block' do
        stream_response.update(text_delta_event)
        expect(stream_response.content_blocks[0]['text']).to eq text_delta_event.data['delta']['text']
      end
    end

    context 'with content_block_start event for tool_use' do
      it 'adds a tool_use content block with empty input string' do
        stream_response.update(tool_use_start_event)
        expect(stream_response.content_blocks[1]).to eq({ **tool_use_start_event.data['content_block'], 'input' => '' })
      end
    end

    context 'with content_block_delta event for tool_use' do
      before do
        stream_response.update(tool_use_start_event)
      end

      it 'appends JSON fragment to the input' do
        stream_response.update(tool_use_delta_event)
        expect(stream_response.content_blocks[1]['input']).to eq(tool_use_delta_event.data['delta']['partial_json'])
      end
    end

    context 'with content_block_stop event for tool_use' do
      before do
        stream_response.update(tool_use_start_event)
        stream_response.update(tool_use_delta_event)
      end

      it 'parses the JSON input' do
        stream_response.update(tool_use_stop_event)
        expect(stream_response.content_blocks[1]['input']).to eq({ 'location' => 'Goodlettsville' })
      end
    end

    context 'with content_block_stop event for tool_use with invalid JSON' do
      let(:invalid_tool_use_delta_event) do
        instance_double(
          GenerativeText::Anthropic::StreamEvent,
          type: 'content_block_delta',
          index: 1,
          delta_type: 'input_json_delta',
          delta_partial_json: '{invalid json',
          data: {
            'index' => 1,
            'delta' => {
              'type' => 'input_json_delta',
              'partial_json' => '{invalid json'
            }
          }
        )
      end

      before do
        stream_response.update(tool_use_start_event)
        stream_response.update(invalid_tool_use_delta_event)
        allow(Rails.logger).to receive(:warn)
      end

      it 'sets input to empty hash and logs warning' do
        stream_response.update(tool_use_stop_event)
        expect(stream_response.content_blocks[1]['input']).to eq({})
      end

      it 'logs a warning' do
        stream_response.update(tool_use_stop_event)
        expect(Rails.logger).to have_received(:warn).with(/invalid JSON tool use input/)
      end
    end

    context 'with message_delta event' do
      before do
        stream_response.update(message_start_event)
      end

      it 'updates the message with delta information' do
        stream_response.update(message_delta_event)
        expect(stream_response.message['stop_reason']).to eq(message_delta_event.data['delta']['stop_reason'])
      end

      it 'updates the usage information' do
        stream_response.update(message_delta_event)
        expect(stream_response.message['usage']['output_tokens']).to eq message_delta_event.usage['output_tokens']
      end
    end

    context 'with message_stop event' do
      it 'sets complete to true' do
        stream_response.update(message_stop_event)
        expect(stream_response.complete).to be true
      end
    end
  end

  describe '#to_response_format' do
    before do
      stream_response.update(message_start_event)
      stream_response.update(text_block_start_event)
      stream_response.update(text_delta_event)
      stream_response.update(message_delta_event)
    end

    it 'merges message and content blocks' do
      response = stream_response.to_response_format
      expect(response).to eq(
        {
          'id' => 'msg_123',
          'model' => 'claude-3-haiku-20240307',
          'role' => 'assistant',
          'content' => [{ 'type' => 'text', 'text' => 'Hello' }],
          'stop_reason' => 'end_turn',
          'stop_sequence' => nil,
          'type' => 'message',
          'usage' => { 'input_tokens' => 10, 'output_tokens' => 20 }
        }
      )
    end
  end

  describe 'full streaming sequence' do
    before do
      [
        message_start_event,
        text_block_start_event,
        text_delta_event,
        text_block_stop_event,
        tool_use_start_event,
        tool_use_delta_event,
        tool_use_stop_event,
        message_delta_event,
        message_stop_event
      ].each do |event|
        stream_response.update(event)
      end
    end

    it 'builds a complete response from a sequence of events' do
      expect(stream_response.to_response_format).to(
        eq(
          {
            'content' => [{ 'text' => 'Hello', 'type' => 'text' },
                          { 'id' => 'toolu_123', 'input' => { 'location' => 'Goodlettsville' },
                            'name' => 'get_weather', 'type' => 'tool_use' }],
            'id' => 'msg_123',
            'model' => 'claude-3-haiku-20240307',
            'role' => 'assistant',
            'stop_reason' => 'end_turn',
            'stop_sequence' => nil,
            'type' => 'message',
            'usage' => { 'input_tokens' => 10, 'output_tokens' => 20 }
          }
        )
      )
    end
  end
end
