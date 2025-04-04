require 'rails_helper'

RSpec.describe Paginate do
  describe '.cursor' do
    let(:relation) { Memo.none }
    let(:collection) { (1..(limit + 1)).map { |i| double(id: i) } }
    let(:limit) { 10 }
    let(:cursor) { 5 }

    before do
      allow(relation).to receive(:where).and_return relation
      allow(relation).to receive(:limit).and_return relation
      allow(relation).to receive(:to_a).and_return collection
    end

    context 'when cursor is provided' do
      it 'limits the relation based on the cursor' do
        described_class.cursor(relation:, limit:, cursor:)
        expect(relation).to have_received(:where).with(id: ..cursor)
      end
    end

    context 'when cursor is blank' do
      it 'limits the relation based on the cursor' do
        described_class.cursor(relation:, limit:, cursor: nil)
        expect(relation).not_to have_received(:where).with(id: ..cursor)
      end
    end

    it 'limits the relation with the specified limit + 1' do
      described_class.cursor(relation:, limit:, cursor:)
      expect(relation).to have_received(:limit).with(limit + 1)
    end

    it 'returns a collection and a cursor' do
      result = described_class.cursor(relation:, limit:, cursor:)
      expect(result).to eq [collection, (limit + 1)]
    end

    context 'when collection size is smaller than the limit' do
      let(:collection) { (1..(limit - 1)).map { |i| double(id: i) } }

      it 'returns nil for the cursor' do
        result = described_class.cursor(relation:, limit:, cursor:)
        expect(result).to eq [collection, nil]
      end
    end

    context 'with an ascending sort order' do
      it 'uses an upward range' do
        described_class.cursor(relation:, limit:, cursor:, order: { created_at: :asc })
        expect(relation).to have_received(:where).with(id: cursor..)
      end
    end
  end

  describe '.paginate' do
    subject(:paginate_result) { described_class.paginate(relation:, page:, per_page:, order:) }

    let(:relation) { instance_double(ActiveRecord::Relation, dup: duped_relation, order: ordered_relation) }
    let(:duped_relation) { instance_double(ActiveRecord::Relation) }
    let(:reselected_relation) { instance_double(ActiveRecord::Relation, count: 6) }
    let(:ordered_relation) { instance_double(ActiveRecord::Relation, limit: limited_relation) }
    let(:limited_relation) { instance_double(ActiveRecord::Relation, offset: paginated_records) }
    let(:paginated_records) { [record1, record2] }
    let(:record1) { instance_double(ActiveRecord::Base, id: 1) }
    let(:record2) { instance_double(ActiveRecord::Base, id: 2) }
    let(:page) { 1 }
    let(:per_page) { 2 }
    let(:order) { { created_at: :desc } }

    before do
      allow(duped_relation).to receive(:reselect).with(:id).and_return(reselected_relation)
    end

    it 'returns the records' do
      records, _metadata = paginate_result
      expect(records).to eq(paginated_records)
    end

    it 'returns the correct metadata' do
      _records, metadata = paginate_result
      expect(metadata).to eq({
        current_page: page,
        per_page:,
        total_count: reselected_relation.count,
        total_pages: 3,
        has_next_page: true,
        has_prev_page: false
      })
    end

    context 'when on the last page' do
      let(:page) { 3 }

      it 'returns metadata with correct pagination flags' do
        _records, metadata = paginate_result
        expect(metadata).to include({
          has_next_page: false,
          has_prev_page: true
        })
      end
    end
  end
end
