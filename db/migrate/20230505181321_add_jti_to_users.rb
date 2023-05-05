class AddJtiToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :jti, :string
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE users
      SET jti = gen_random_uuid();
    SQL
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end

  def down
    remove_column :users, :jti
  end
end
