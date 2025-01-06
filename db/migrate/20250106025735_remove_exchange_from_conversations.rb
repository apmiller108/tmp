class RemoveExchangeFromConversations < ActiveRecord::Migration[7.1]
  def change
    remove_column :conversations, :exchange, :jsonb, null: false
  end
end
