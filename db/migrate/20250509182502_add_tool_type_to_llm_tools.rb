class AddToolTypeToLlmTools < ActiveRecord::Migration[8.0]
  def up
    add_column :llm_tools, :tool_type, :string, limit: 24

    execute <<~SQL
      UPDATE llm_tools SET tool_type = 'image' WHERE name = 'GenerateImage'
    SQL

    change_column_null :llm_tools, :tool_type, false
  end

  def down
    remove_column :llm_tools, :tool_type
  end
end
