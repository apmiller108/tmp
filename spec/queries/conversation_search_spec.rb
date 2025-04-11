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
      let(:filtered_relation) { instance_double(ActiveRecord::Relation) }

      before do
        allow(Embeddings::Voyage).to receive(:create_embeddings)
          .with(text: 'search query', input_type: :query)
          .and_return(embeddings_response)

        allow(relation).to receive(:similar_to)
          .with(vector, described_class::VECTOR_RELEVANCE_THRESHOLD)
          .and_return(filtered_relation)
      end

      it 'applies the semantic filter' do
        expect(search.results).to eq(filtered_relation)
      end

      it 'adds semantic to applied_filters' do
        search.results
        expect(search.applied_filters).to include(described_class::SEMANTIC)
      end
    end

    context 'with the conversation_id param' do
      let(:params) { { conversation_id: '99' } }
      let(:vector) { [0.1, 0.2, 0.3] }
      let(:conversation) { build_stubbed(:conversation, id: 99, embedding: vector) }
      let(:filtered_relation) { instance_double(ActiveRecord::Relation) }
      let(:where_chain) { instance_double(ActiveRecord::QueryMethods::WhereChain) }
      let(:final_relation) { instance_double(ActiveRecord::Relation) }

      before do
        allow(Conversation).to receive(:find).with('99').and_return(conversation)
        allow(relation).to receive(:similar_to)
          .with(vector, described_class::VECTOR_RELEVANCE_THRESHOLD)
          .and_return(filtered_relation)
        allow(filtered_relation).to receive(:where).and_return(where_chain)
        allow(where_chain).to receive(:not).with(id: '99').and_return(final_relation)
      end

      it 'applies the related conversations filter' do
        expect(search.results).to eq(final_relation)
      end

      it 'adds related conversations to the applied filters' do
        search.results
        expect(search.applied_filters).to include(described_class::RELATED_CONVERSATIONS)
      end
    end

    context 'with both memo_id and search term params' do
      let(:params) { { memo_id: 123, term: 'search query' } }
      let(:vector) { [0.1, 0.2, 0.3] }
      let(:embeddings) { [Embeddings::Voyage::EmbeddingResponse::Embedding.new(vector:, index: 0)] }
      let(:embeddings_response) { instance_double(Embeddings::Voyage::EmbeddingResponse, embeddings:) }
      let(:memo_filtered_relation) { double('Conversation::ActiveRecord_Relation') }
      let(:final_relation) { instance_double(ActiveRecord::Relation) }

      before do
        allow(relation).to receive(:where).with(memo_id: 123).and_return(memo_filtered_relation)

        allow(Embeddings::Voyage).to receive(:create_embeddings)
          .with(text: 'search query', input_type: :query)
          .and_return(embeddings_response)

        allow(memo_filtered_relation).to receive(:similar_to)
          .with(vector, described_class::VECTOR_RELEVANCE_THRESHOLD)
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

      context 'when vector search was applied' do
        before do
          search.applied_filters << [described_class::SEMANTIC, described_class::RELATED_CONVERSATIONS].sample
        end

        it 'returns the correct order hash' do
          expect(search.order).to eq({ neighbor_distance: :asc })
        end
      end

      it 'returns the default order hash' do
        expect(search.order).to eq({ updated_at: :desc })
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
