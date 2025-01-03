class AddTitleToConversations < ActiveRecord::Migration[7.1]
  def up
    add_column :conversations, :title, :string, limit: 100

    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE conversations c
      SET title = REPLACE(LEFT((exchange->0->'content'->0->'text')::text, 35), '"', '');
    SQL

    change_column_null :conversations, :title, false
  end

  def down
    remove_column :conversations, :title
  end
end
