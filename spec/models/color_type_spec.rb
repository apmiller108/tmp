require 'rails_helper'

RSpec.describe ColorType, type: :model do
  let(:hex) { '03045e' }

  describe 'DEFAULT' do
    subject { described_class::DEFAULT }

    it { is_expected.to eq 'e4f2fe' }
  end

  describe '#initialize' do
    it 'uses the default hex if none is provided' do
      color_type = described_class.new
      expect(color_type.hex).to eq(described_class::DEFAULT)
    end

    it 'uses the provided hex if one is provided' do
      color_type = described_class.new(hex)
      expect(color_type.hex).to eq(hex)
    end
  end

  describe '#serialize' do
    it 'returns the hex string' do
      color_type = described_class.new
      expect(color_type.serialize(color_type)).to eq(color_type.hex)
    end
  end

  describe '#deserialize' do
    subject(:color_type) { described_class.new }

    it 'creates a new instance with the provided value' do
      deserialized = color_type.deserialize(hex)
      expect(deserialized).to be_a described_class
    end

    it 'sets the value to the hex property' do
      deserialized = color_type.deserialize(hex)
      expect(deserialized.hex).to eq hex
    end
  end

  describe '#to_rgb' do
    it 'returns an array with RGB values' do
      color_type = described_class.new(hex)
      expect(color_type.to_rgb).to eq([3, 4, 94])
    end
  end

  describe '#darkish?' do
    it 'returns true for low saturation color' do
      color_type = described_class.new('000000')
      expect(color_type.darkish?).to be true
    end

    it 'returns false for a high saturated color' do
      color_type = described_class.new('ffffff')
      expect(color_type.darkish?).to be false
    end
  end

  describe '#default?' do
    it 'returns true for the default hex' do
      color_type = described_class.new
      expect(color_type.default?).to be true
    end

    it 'returns false for a custom hex' do
      color_type = described_class.new(hex)
      expect(color_type.default?).to be false
    end
  end
end
