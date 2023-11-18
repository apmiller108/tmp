class AddMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages, id: :primary_key do |t|
      t.references :user, index: true, null: false, foreign_key: { on_delete: :cascade }
    end
  end
end
