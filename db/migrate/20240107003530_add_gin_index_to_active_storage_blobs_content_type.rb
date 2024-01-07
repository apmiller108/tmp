class AddGinIndexToActiveStorageBlobsContentType < ActiveRecord::Migration[7.1]
  def up
    enable_extension :pg_trgm
    add_index :active_storage_blobs, :content_type, using: :gin, opclass: :gin_trgm_ops
  end

  def down
    remove_index :active_storage_blobs, :content_type
  end
end
