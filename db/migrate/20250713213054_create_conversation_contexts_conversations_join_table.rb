class CreateConversationContextsConversationsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_contexts_conversations, id: false do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :conversation_context, null: false, foreign_key: true
    end

    add_index :conversation_contexts_conversations,
              [:conversation_id, :conversation_context_id],
              unique: true,
              name: 'index_conversations_on_contexts'
  end
end
