class CreateGenerateImageRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :generate_image_requests do |t|
      t.string :image_id, limit: 50, null: false
      t.string :style, limit: 50
      t.string :dimensions, null: false, limit: 25
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
