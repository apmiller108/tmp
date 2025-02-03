class CreateConversationTurns < ActiveRecord::Migration[7.2]
  def up
    create_table :conversation_turns do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :turnable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :conversation_turns, [:conversation_id, :created_at]

    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO conversation_turns 
        (conversation_id, turnable_type, turnable_id, created_at, updated_at)
      SELECT 
        conversation_id,
        'GenerateTextRequest',
        id,
        created_at,
        updated_at
      FROM generate_text_requests
      WHERE generate_text_requests.conversation_id IS NOT NULL;

      INSERT INTO conversation_turns 
        (conversation_id, turnable_type, turnable_id, created_at, updated_at)
      SELECT 
        conversation_id,
        'GenerateImageRequest',
        id,
        created_at,
        updated_at
      FROM generate_image_requests
      WHERE generate_image_requests.conversation_id IS NOT NULL;
    SQL
  end

  def down
    drop_table :conversation_turns
  end
end
