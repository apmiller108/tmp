class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :memo, foreign_key: true
      t.references :user, foreign_key: true
      t.jsonb :exchange, null: false

      t.timestamps
    end
  end
end
