class RenameGenerativeTextPresetAndAddColumns < ActiveRecord::Migration[7.1]
  def change
    rename_table :generative_text_presets, :generate_text_presets

    add_column :generate_text_requests, :temperature, :float
    add_reference :generate_text_requests, :generate_text_preset, foreign_key: true
  end
end
