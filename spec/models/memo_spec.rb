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
end
