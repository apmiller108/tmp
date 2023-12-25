class RenameMessagesToMemo < ActiveRecord::Migration[7.1]
  def up
    remove_foreign_key :messages, :users
    remove_index :messages, :user_id

    rename_table :messages, :memos

    add_foreign_key :memos, :users, on_delete: :cascade
    add_index :memos, :user_id
  end

  def down
    remove_foreign_key :memos, :users
    remove_index :messages, :user_id

    rename_table :memos, :messages

    add_foreign_key :messages, :users, on_delete: :cascade
    add_index :messages, :user_id
  end
end
