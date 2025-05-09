class AddToolTypesToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :tool_types, :string, array: true, default: []
  end
end
