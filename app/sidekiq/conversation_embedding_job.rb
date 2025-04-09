class ConversationEmbeddingJob
  include Sidekiq::Job

  sidekiq_options lock: :until_executed

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    response = Embeddings::Voyage.create_embeddings(text: conversation.blobify, input_type: :document)

    conversation.update!(embedding: response.embeddings.first.vector)

    MyChannel.broadcast_to(conversation.user, {
      embedding_created: { conversation_id: }
    })
  end
end
