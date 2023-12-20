module ActiveStorageBlobExtension
  extend ActiveSupport::Concern

  included do
    has_one :transcription_job, foreign_key: :active_storage_blob_id, dependent: :destroy
    has_one :transcription, foreign_key: :active_storage_blob_id, dependent: :destroy
  end
end
