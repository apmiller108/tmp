require 'rails_helper'

RSpec.describe Transcription::SpeakerContent::Item do
  subject(:item) { described_class.new(item_data) }

  let(:content) { 'crucial' }
  let(:speaker) { 'spk_0'}
  let(:item_data) do
    {
      'type' => 'pronunciation',
      'end_time' => '5.0',
      'start_time' => '1.0',
      'alternatives' => [{ 'content' => content, 'confidence' => '0.99' }],
      'speaker_label' => speaker
    }
  end

  describe '#initialize' do
    it 'sets the content correctly' do
      expect(item.content).to eq(content)
    end
  end

  describe '#speaker' do
    it 'returns the correct speaker' do
      expect(item.speaker).to eq(speaker)
    end
  end

  describe '#speaker_same_as?' do
    it 'returns true if speakers are the same' do
      other_item = described_class.new(item_data)
      expect(item.speaker_same_as?(other_item)).to be true
    end

    it 'returns false if speakers are different' do
      other_item = described_class.new(item_data.merge('speaker_label' => 'spk_1'))
      expect(item.speaker_same_as?(other_item)).to be false
    end
  end

  describe '#combinable_value' do
    it 'returns content for punctuation items with whitespace padding' do
      item_data['type'] = 'punctuation'
      item_data['alternatives'][0]['content'] = '?'
      expect(item.combinable_value).to eq('?')
    end

    it 'returns content with whitespace padding for non-punctuation items' do
      expect(item.combinable_value).to eq(' crucial')
    end
  end

  describe '#punctuation?' do
    it 'returns true for punctuation items' do
      item_data['type'] = 'punctuation'
      expect(item.punctuation?).to be true
    end

    it 'returns false for non-punctuation items' do
      expect(item.punctuation?).to be false
    end
  end

  describe '#combine_with' do
    let(:other_item_data) do
      {
        'type' => 'pronunciation',
        'end_time' => '10.3',
        'start_time' => '5.1',
        'alternatives' => [{ 'content' => 'test', 'confidence' => '0.95' }],
        'speaker_label' => speaker
      }
    end

    it 'combines the content of two items' do
      other_item = described_class.new(other_item_data)
      combined = item.combine_with(other_item)
      expect(combined.item_data).to(
        eq(
          'type' => 'combined',
          'start_time' => item_data['start_time'],
          'end_time' => other_item_data['end_time'],
          'alternatives' => [{ 'confidence' => '0.97', 'content' => 'crucial test'}],
          'speaker_label' => speaker
        )
      )
    end

    context 'when the speakers do not match' do
      it 'raises an argument error' do
        other_item = described_class.new(other_item_data.merge('speaker_label' => 'spk_1'))
        expect { item.combine_with(other_item) }.to raise_error ArgumentError, 'Speakers must match in order to combine items'
      end
    end
  end
end
