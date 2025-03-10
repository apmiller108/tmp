require 'rails_helper'

RSpec.describe GenerativeText::Anthropic::StreamEvent do
  subject(:stream_event) { described_class.new(type: event_type, data: event_data) }

  let(:event_type) { 'content_block_delta' }
  let(:event_data) { { 'index' => 0, 'delta' => { 'type' => 'text_delta', 'text' => 'Hello' } } }

  describe '.parse' do
    subject(:parsed_event) { described_class.parse(raw_event) }

    context 'with a valid text delta event' do
      let(:raw_event) do
        "event: content_block_delta\ndata: "\
        '{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}'
      end

      it 'returns a StreamEvent instance' do
        expect(parsed_event).to be_a(described_class)
      end

      it 'sets the correct type' do
        expect(parsed_event.type).to eq('content_block_delta')
      end

      it 'parses the data correctly' do
        expect(parsed_event.data).to eq(
          'type' => 'content_block_delta',
          'index' => 0,
          'delta' => { 'type' => 'text_delta', 'text' => 'Hello' }
        )
      end
    end

    context 'with a ping event' do
      let(:raw_event) { "event: ping\ndata: {\"type\":\"ping\"}" }

      it 'returns nil' do
        expect(parsed_event).to be_nil
      end
    end

    context 'with invalid JSON' do
      let(:raw_event) { "event: content_block_delta\ndata: {invalid json}" }

      before do
        allow(Rails.logger).to receive(:warn)
      end

      it 'returns nil' do
        expect(parsed_event).to be_nil
      end

      it 'logs a warning' do
        parsed_event
        expect(Rails.logger).to have_received(:warn).with(/invalid json/)
      end
    end

    context 'with missing event type' do
      let(:raw_event) { 'data: {"type":"content_block_delta"}' }

      it 'returns nil' do
        expect(parsed_event).to be_nil
      end
    end

    context 'with missing data' do
      let(:raw_event) { 'event: content_block_delta' }

      it 'returns nil' do
        expect(parsed_event).to be_nil
      end
    end
  end

  describe '.parse_raw_event' do
    subject(:parsed_raw_event) { described_class.parse_raw_event(raw_event) }

    context 'with a complete event' do
      let(:raw_event) do
        "event: content_block_delta\ndata: {\"type\":\"content_block_delta\",\"index\":0}"
      end

      it 'returns the event type and data' do
        expect(parsed_raw_event).to eq(['content_block_delta', '{"type":"content_block_delta","index":0}'])
      end
    end

    context 'with a multi-line event' do
      let(:raw_event) do
        "event: content_block_delta\ndata: {\"type\":\"content_block_delta\"}\nsome_other_field: value"
      end

      it 'extracts only the event and data fields' do
        expect(parsed_raw_event).to eq(['content_block_delta', '{"type":"content_block_delta"}'])
      end
    end

    context 'with missing fields' do
      let(:raw_event) { 'some_other_field: value' }

      it 'returns nil values' do
        expect(parsed_raw_event).to eq([nil, nil])
      end
    end
  end

  describe '#content_block_start?' do
    context 'when type is content_block_start' do
      let(:event_type) { 'content_block_start' }

      it 'returns true' do
        expect(stream_event.content_block_start?).to be true
      end
    end

    context 'when type is not content_block_start' do
      let(:event_type) { 'content_block_delta' }

      it 'returns false' do
        expect(stream_event.content_block_start?).to be false
      end
    end
  end

  describe '#content_block_delta?' do
    context 'when type is content_block_delta' do
      let(:event_type) { 'content_block_delta' }

      it 'returns true' do
        expect(stream_event.content_block_delta?).to be true
      end
    end

    context 'when type is not content_block_delta' do
      let(:event_type) { 'content_block_start' }

      it 'returns false' do
        expect(stream_event.content_block_delta?).to be false
      end
    end
  end

  describe '#text_content' do
    context 'with a content_block_start event with text type' do
      let(:event_type) { 'content_block_start' }
      let(:event_data) { { 'content_block' => { 'type' => 'text', 'text' => 'Hello world' } } }

      it 'returns the text content' do
        expect(stream_event.text_content).to eq('Hello world')
      end
    end

    context 'with a content_block_delta event with text_delta type' do
      let(:event_type) { 'content_block_delta' }
      let(:event_data) { { 'delta' => { 'type' => 'text_delta', 'text' => 'Hello' } } }

      it 'returns the delta text' do
        expect(stream_event.text_content).to eq('Hello')
      end
    end

    context 'with a non-text event' do
      let(:event_type) { 'content_block_start' }
      let(:event_data) { { 'content_block' => { 'type' => 'tool_use' } } }

      it 'returns nil' do
        expect(stream_event.text_content).to be_nil
      end
    end
  end

  describe '#content_block_type' do
    context 'with a content_block_start event' do
      let(:event_type) { 'content_block_start' }
      let(:event_data) { { 'content_block' => { 'type' => 'text' } } }

      it 'returns the content block type' do
        expect(stream_event.content_block_type).to eq('text')
      end
    end

    context 'with an event without content_block' do
      let(:event_data) { { 'delta' => { 'type' => 'text_delta' } } }

      it 'returns nil' do
        expect(stream_event.content_block_type).to be_nil
      end
    end
  end

  describe '#text?' do
    let(:event_type) { 'content_block_delta' }
    let(:event_data) { { 'index' => 0, 'delta' => { 'type' => 'text_delta', 'text' => text_content } } }

    context 'when text_content is present' do
      let(:text_content) { 'Hello' }

      it 'returns true' do
        expect(stream_event.text?).to be true
      end
    end

    context 'when text_content is nil' do
      let(:text_content) { nil }

      it 'returns false' do
        expect(stream_event.text?).to be false
      end
    end

    context 'when text_content is empty' do
      let(:text_content) { '' }

      it 'returns false' do
        expect(stream_event.text?).to be false
      end
    end
  end

  describe '#index' do
    context 'when index is present in data' do
      let(:event_data) { { 'index' => 2 } }

      it 'returns the index' do
        expect(stream_event.index).to eq(2)
      end
    end

    context 'when index is not present in data' do
      let(:event_data) { {} }

      it 'returns nil' do
        expect(stream_event.index).to be_nil
      end
    end
  end

  describe '#delta_type' do
    context 'with a content_block_delta event' do
      let(:event_data) { { 'delta' => { 'type' => 'text_delta' } } }

      it 'returns the delta type' do
        expect(stream_event.delta_type).to eq('text_delta')
      end
    end

    context 'with an event without delta' do
      let(:event_data) { {} }

      it 'returns nil' do
        expect(stream_event.delta_type).to be_nil
      end
    end
  end

  describe '#delta_text' do
    context 'with a text_delta event' do
      let(:event_data) { { 'delta' => { 'type' => 'text_delta', 'text' => 'Hello' } } }

      it 'returns the delta text' do
        expect(stream_event.delta_text).to eq('Hello')
      end
    end

    context 'with an event without delta text' do
      let(:event_data) { { 'delta' => { 'type' => 'text_delta' } } }

      it 'returns nil' do
        expect(stream_event.delta_text).to be_nil
      end
    end
  end

  describe '#delta_partial_json' do
    context 'with an input_json_delta event' do
      let(:event_data) { { 'delta' => { 'type' => 'input_json_delta', 'partial_json' => '{"key":' } } }

      it 'returns the partial JSON' do
        expect(stream_event.delta_partial_json).to eq('{"key":')
      end
    end

    context 'with an event without partial_json' do
      let(:event_data) { { 'delta' => { 'type' => 'input_json_delta' } } }

      it 'returns nil' do
        expect(stream_event.delta_partial_json).to be_nil
      end
    end
  end

  describe '#usage' do
    context 'when usage is present in data' do
      let(:event_data) { { 'usage' => { 'output_tokens' => 10 } } }

      it 'returns the usage data' do
        expect(stream_event.usage).to eq({ 'output_tokens' => 10 })
      end
    end

    context 'when usage is not present in data' do
      let(:event_data) { {} }

      it 'returns an empty hash' do
        expect(stream_event.usage).to eq({})
      end
    end
  end
end
