class BlobsController < ApplicationController
  def show
    blob = ActiveStorage::Blob.associated_with_user(current_user.id)
                              .find(params[:active_storage_blob_id])
    send_data(blob.download, filename: blob.filename.to_s, disposition: :attachment)
  end
end
