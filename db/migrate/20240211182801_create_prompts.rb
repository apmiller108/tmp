class CreatePrompts < ActiveRecord::Migration[7.1]
  def change
    create_table :prompts do |t|
      t.text :text, null: false
      t.integer :weight, null: false, default: 1
      t.check_constraint "weight >= -10 AND weight <= 10", name: 'weight_check'
      t.references :generate_image_requests, null: false, foreign_key: true

      t.timestamps
    end
  end
end
