class AddTitleToMemos < ActiveRecord::Migration[7.1]
  def change
    add_column :memos, :title, :string, limit: 100, null: false, default: 'memo title'
    change_column_default :memos, :title, from: 'memo title', to: nil
  end
end
