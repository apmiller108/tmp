class CreateGenerateTextPresetsUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :generate_text_presets_users do |t|
      t.references :generate_text_preset, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
