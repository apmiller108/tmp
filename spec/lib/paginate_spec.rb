require 'rails_helper'

RSpec.describe Paginate do
  describe '.call' do
    let(:relation) { Memo.none }
    let(:collection) { (1..(limit + 1)).map { |i| double(id: i) } } # rubocop:disable RSpec/VerifiedDoubles
    let(:limit) { 10 }
    let(:cursor) { 5 }

    before do
      allow(relation).to receive(:where).and_return relation
      allow(relation).to receive(:limit).and_return relation
      allow(relation).to receive(:to_a).and_return collection
    end

    context 'when cursor is provided' do
      it 'limits the relation based on the cursor' do
        described_class.call(relation:, limit:, cursor:)
        expect(relation).to have_received(:where).with(id: ..cursor)
      end
    end

    context 'when cursor is blank' do
      it 'limits the relation based on the cursor' do
        described_class.call(relation:, limit:, cursor: nil)
        expect(relation).not_to have_received(:where).with(id: ..cursor)
      end
    end

    it 'limits the relation with the specified limit + 1' do
      described_class.call(relation:, limit:, cursor:)
      expect(relation).to have_received(:limit).with(limit + 1)
    end

    it 'returns a collection and a cursor' do
      result = described_class.call(relation:, limit:, cursor:)
      expect(result).to eq [collection, (limit + 1)]
    end

    context 'when collection size is smaller than the limit' do
      let(:collection) { (1..(limit - 1)).map { |i| double(id: i) } } # rubocop:disable RSpec/VerifiedDoubles

      it 'returns nil for the cursor' do
        result = described_class.call(relation:, limit:, cursor:)
        expect(result).to eq [collection, nil]
      end
    end

    context 'with an ascending sort order' do
      it 'uses an upward range' do
        described_class.call(relation:, limit:, cursor:, order: { created_at: :asc })
        expect(relation).to have_received(:where).with(id: cursor..)
      end
    end
  end
end
