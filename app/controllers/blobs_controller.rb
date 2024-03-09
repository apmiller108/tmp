class BlobsController < ApplicationController
  def show
    blob = ActiveStorage::Blob.joins(:memo)
                              .where(memo: { user_id: current_user.id })
                              .find(params[:active_storage_blob_id])
    send_data(blob.download, filename: blob.filename.to_s, disposition: :attachment)
  end
end
