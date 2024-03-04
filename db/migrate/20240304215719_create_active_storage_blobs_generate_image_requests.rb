class CreateActiveStorageBlobsGenerateImageRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :active_storage_blobs_generate_image_requests, id: false do |t|
      t.references :generate_image_request, null: false, foreign_key: true
      t.references :active_storage_blob, null: false, foreign_key: true
    end
  end
end
