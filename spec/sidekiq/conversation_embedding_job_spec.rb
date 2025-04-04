require 'rails_helper'

RSpec.describe ConversationEmbeddingJob, type: :job do
  subject(:job) { described_class.new }

  describe '#perform' do
    let(:conversation_id) { 1 }
    let(:conversation) { build_stubbed(:conversation) }
    let(:blobified_convo) { 'blobified convo' }
    let(:embedding_vector) { [0.1, 0.2, 0.3] }
    let(:embedding_response) do
      instance_double(
        Embeddings::Voyage::EmbeddingResponse,
        embeddings: [instance_double(Embeddings::Voyage::EmbeddingResponse::Embedding, vector: embedding_vector)]
      )
    end

    before do
      allow(Conversation).to receive(:find).with(conversation_id).and_return(conversation)
      allow(Embeddings::Voyage).to receive(:create_embeddings)
        .with(text: blobified_convo, input_type: :document)
        .and_return(embedding_response)
      allow(conversation).to receive(:blobify).and_return(blobified_convo)
      allow(conversation).to receive(:update!)
    end

    it 'finds the conversation by id' do
      job.perform(conversation_id)
      expect(Conversation).to have_received(:find).with(conversation_id)
    end

    it 'updates the conversation with the embedding vector' do
      job.perform(conversation_id)
      expect(conversation).to have_received(:update!).with(embedding: embedding_vector)
    end
  end

  describe 'sidekiq options' do
    it 'sets the lock option to :until_executed' do
      expect(described_class.sidekiq_options_hash['lock']).to eq(:until_executed)
    end
  end
end
