require 'rails_helper'

RSpec.describe Transcription::SpeakerContent do
  subject(:speaker_content) { described_class.new(speaker_data) }

  let(:speaker_data) do
    [
      { 'type' => 'pronunciation', 'speaker_label' => 'spk_0', 'alternatives' => [{ 'content' => 'hello' }] },
      { 'type' => 'pronunciation', 'speaker_label' => 'spk_0', 'alternatives' => [{ 'content' => 'world' }] },
      { 'type' => 'punctuation', 'speaker_label' => 'spk_0', 'alternatives' => [{ 'content' => '!' }] },
      { 'type' => 'pronunciation', 'speaker_label' => 'spk_1', 'alternatives' => [{ 'content' => 'Yes' }] },
      { 'type' => 'punctuation', 'speaker_label' => 'spk_1', 'alternatives' => [{ 'content' => ',' }] },
      { 'type' => 'pronunciation', 'speaker_label' => 'spk_1', 'alternatives' => [{ 'content' => 'Moon' }] },
      { 'type' => 'punctuation', 'speaker_label' => 'spk_1', 'alternatives' => [{ 'content' => '?' }] }
    ]
  end

  describe '#initialize' do
    it 'creates items from speaker data' do
      expect(speaker_content.content).to all(be_an(Transcription::SpeakerContent::Item))
    end
  end

  describe '#squash' do
    it 'creates the expected number of items' do
      expect(speaker_content.squash.count).to eq 2
    end

    it 'combines items with the same speaker label' do
      squashed = speaker_content.squash

      expect(squashed.map { |item| [item.speaker, item.content] }).to(
        eq([
             ['spk_0', 'hello world!'],
             ['spk_1', 'Yes, Moon?']
           ])
      )
    end
  end
end
