class AddDeveloperToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :developer, :boolean, null: false, default: false
  end
end
