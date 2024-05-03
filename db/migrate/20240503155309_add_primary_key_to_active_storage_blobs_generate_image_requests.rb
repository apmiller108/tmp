class AddPrimaryKeyToActiveStorageBlobsGenerateImageRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :active_storage_blobs_generate_image_requests, :id, :primary_key
  end
end
