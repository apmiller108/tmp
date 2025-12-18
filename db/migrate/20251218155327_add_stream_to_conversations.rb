class AddStreamToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :stream, :boolean, default: true, null: false
  end
end
