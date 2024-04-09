class CreateGenerativeTextPresets < ActiveRecord::Migration[7.1]
  def change
    create_table :generative_text_presets do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.text :system_message, null: false
      t.integer :temperature, null: false

      t.timestamps
    end
  end
end
