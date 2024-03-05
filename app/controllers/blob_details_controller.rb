class BlobDetailsController < ApplicationController
  def show
    @blob = ActiveStorage::Blob.find(params[:active_storage_blob_id])
    respond_to(&:html)
  end
end
