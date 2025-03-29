namespace :conversations do
  desc 'Creates embeddings for existing conversations that do not have embeddings'
  task create_embeddings: :environment do
    Conversation.where(embedding: nil).find_each do |conversation|
      response = Embeddings::Voyage.create_embeddings(text: conversation.blobify, input_type: :document)
      conversation.embedding = response.embeddings.first.vector

      if conversation.save
        puts "Created embedding for conversation : #{conversation.id}"
      else
        puts "Failed to create embedding for conversation: #{conversation.id}: #{conversation.errors.full_messages}"
      end
    end
  end
end
