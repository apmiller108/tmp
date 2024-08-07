class CreateGenerateTextRequest < ActiveRecord::Migration[7.1]
  def change
    create_table :generate_text_requests do |t|
      t.string :text_id, limit: 50, null: false
      t.text :prompt, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
