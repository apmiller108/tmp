class ActiveStorageBlobsGenerateImageRequest < ApplicationRecord
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'
  belongs_to :generate_image_request
end
