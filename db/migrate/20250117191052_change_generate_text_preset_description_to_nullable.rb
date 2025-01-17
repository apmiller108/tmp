class ChangeGenerateTextPresetDescriptionToNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :generate_text_presets, :description, true
  end
end
