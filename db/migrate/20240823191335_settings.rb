class Settings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :text_model

      t.timestamps
    end
  end
end
