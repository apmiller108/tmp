class ChangeImageIdToImageName < ActiveRecord::Migration[7.1]
  def change
    rename_column :generate_image_requests, :image_id, :image_name
    add_reference :generate_image_requests, :active_storage_blob, null: true, foreign_key: true
  end
end
