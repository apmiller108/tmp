class AddEmbeddingToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :embedding, :vector, limit: 1024
  end
end
