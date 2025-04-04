require 'rails_helper'

RSpec.describe ConversationSearch do
  subject(:search) { described_class.new(relation:, params:) }

  let(:relation) { Conversation.all }
  let(:params) { {} }

  describe '#results' do
    context 'when params is blank' do
      let(:params) { {} }

      it 'returns the original relation' do
        expect(search.results).to eq(relation)
      end
    end

    context 'with memo_id param' do
      let(:params) { { memo_id: 123 } }
      let(:filtered_relation) { instance_double(ActiveRecord::Relation) }

      before do
        allow(relation).to receive(:where).with(memo_id: 123).and_return(filtered_relation)
      end

      it 'applies the memo filter' do
        expect(search.results).to eq(filtered_relation)
      end
    end

    context 'with search term param' do
      let(:params) { { term: 'search query' } }
      let(:vector) { [0.1, 0.2, 0.3] }
      let(:embeddings) { [Embeddings::Voyage::EmbeddingResponse::Embedding.new(vector:, index: 0)] }
      let(:embeddings_response) { instance_double(Embeddings::Voyage::EmbeddingResponse, embeddings:) }
      let(:selected_relation) { instance_double(ActiveRecord::Relation) }
      let(:filtered_relation) { instance_double(ActiveRecord::Relation) }

      before do
        allow(Embeddings::Voyage).to receive(:create_embeddings)
          .with(text: 'search query', input_type: :query)
          .and_return(embeddings_response)

        allow(relation).to receive(:select)
          .with("conversations.*, (embedding <=> '#{vector}') AS neighbor_distance")
          .and_return(selected_relation)

        allow(selected_relation).to receive(:where)
          .with('embedding <=> ? < ?', vector.to_s, described_class::VECTOR_RELEVANCE_THRESHOLD)
          .and_return(filtered_relation)
      end

      it 'applies the semantic filter' do
        expect(search.results).to eq(filtered_relation)
      end

      it 'adds semantic to applied_filters' do
        search.results
        expect(search.applied_filters).to include(:semantic)
      end
    end

    context 'with both memo_id and search term params' do
      let(:params) { { memo_id: 123, term: 'search query' } }
      let(:vector) { [0.1, 0.2, 0.3] }
      let(:embeddings) { [Embeddings::Voyage::EmbeddingResponse::Embedding.new(vector:, index: 0)] }
      let(:embeddings_response) { instance_double(Embeddings::Voyage::EmbeddingResponse, embeddings:) }
      let(:memo_filtered_relation) { instance_double(ActiveRecord::Relation) }
      let(:selected_relation) { instance_double(ActiveRecord::Relation) }
      let(:final_relation) { instance_double(ActiveRecord::Relation) }

      before do
        allow(relation).to receive(:where).with(memo_id: 123).and_return(memo_filtered_relation)

        allow(Embeddings::Voyage).to receive(:create_embeddings)
          .with(text: 'search query', input_type: :query)
          .and_return(embeddings_response)

        allow(memo_filtered_relation).to receive(:select)
          .with("conversations.*, (embedding <=> '#{vector}') AS neighbor_distance")
          .and_return(selected_relation)

        allow(selected_relation).to receive(:where)
          .with('embedding <=> ? < ?', vector.to_s, described_class::VECTOR_RELEVANCE_THRESHOLD)
          .and_return(final_relation)
      end

      it 'applies both filters' do
        expect(search.results).to eq(final_relation)
      end
    end
  end

  describe '#order' do
    context 'when order param is "neighbor_distance asc"' do
      let(:params) { { order: 'neighbor_distance asc' } }

      it 'returns the correct order hash' do
        expect(search.order).to eq({ neighbor_distance: :asc })
      end
    end

    context 'when order param is not specified' do
      let(:params) { {} }

      it 'returns the default order hash' do
        expect(search.order).to eq({ updated_at: :desc })
      end
    end

    context 'when order param is something else' do
      let(:params) { { order: 'something else' } }

      it 'returns the default order hash' do
        expect(search.order).to eq({ updated_at: :desc })
      end
    end
  end
end
