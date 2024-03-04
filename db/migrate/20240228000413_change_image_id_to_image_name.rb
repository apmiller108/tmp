class ChangeImageIdToImageName < ActiveRecord::Migration[7.1]
  def change
    rename_column :generate_image_requests, :image_id, :image_name
  end
end
