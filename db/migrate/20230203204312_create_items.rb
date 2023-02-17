class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.boolean :done, null: false, default: false

      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
