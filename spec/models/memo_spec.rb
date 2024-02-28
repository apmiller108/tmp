require 'rails_helper'

RSpec.describe Memo, type: :model do
  describe 'color attribute' do
    let(:color) { Memo::COLORS.sample }

    it 'deserializes to a color type' do
      memo = create(:memo, color:)
      expect(memo.color).to be_a ColorType
    end

    it 'persists the raw color value' do
      memo = create(:memo, color:)
      expect(memo.color_before_type_cast).to eq color
    end
  end

  describe 'default_color?' do
    context 'when color is a string' do
      context 'when the value is blank' do
        subject { described_class.new(color: '') }

        it { is_expected.to be_default_color }
      end

      context 'when the value is the default hex' do
        subject { described_class.new(color: ColorType::DEFAULT) }

        it { is_expected.to be_default_color }
      end

      context 'when the value is not the default hex' do
        subject { described_class.new(color: described_class::SWATCHES.values.flatten.sample) }

        it { is_expected.not_to be_default_color }
      end
    end

    context 'when color is a ColorType' do
      context 'when it is the default color' do
        subject { create(:memo, color: ColorType::DEFAULT) }

        it { is_expected.to be_default_color }
      end

      context 'when it is not the default color' do
        subject { create(:memo, color: described_class::SWATCHES.values.flatten.sample) }

        it { is_expected.not_to be_default_color }
      end
    end
  end
end
