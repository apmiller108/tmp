class AssociateBlobToGenerateImageRequestJob
  include Sidekiq::Job

  def perform(active_storage_blob_id)
    blob = ActiveStorage::Blob.find(active_storage_blob_id)
    return unless blob.text_to_image?

    request = GenerateImageRequest.find_by!(image_name: blob.filename.base)
    request.active_storage_blob = blob
    request.save!
  end
end