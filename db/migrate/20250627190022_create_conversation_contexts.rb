class CreateConversationContexts < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_contexts do |t|
      t.string :file_ref, null: false
      t.references :conversation, null: false, foreign_key: true
      t.string :filename, null: false
      t.string :mime_type, null: false
      t.string :context_type, null: false

      t.timestamps
    end
  end
end
