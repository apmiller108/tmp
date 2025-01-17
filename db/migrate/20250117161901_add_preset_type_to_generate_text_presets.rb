class AddPresetTypeToGenerateTextPresets < ActiveRecord::Migration[7.2]
  def up
    add_column :generate_text_presets, :preset_type, :text
    add_check_constraint :generate_text_presets, "preset_type in ('default', 'custom')", name: 'preset_type_check'

    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE generate_text_presets
      SET preset_type = 'default'
    SQL

    change_column_null :generate_text_presets, :preset_type, false
  end

  def down
    remove_check_constraint :generate_text_presets, name: 'preset_type_check'
    remove_column :generate_text_presets, :preset_type
  end
end

