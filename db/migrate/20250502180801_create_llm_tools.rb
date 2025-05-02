class CreateLlmTools < ActiveRecord::Migration[8.0]
  def change
    create_table :llm_tools do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.jsonb :input_schema, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :llm_tools, :name, unique: true
  end
end
