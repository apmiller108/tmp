class AddIndexToGenerateImageRequestImageName < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :generate_image_requests, :image_name, algorithm: :concurrently
  end
end
