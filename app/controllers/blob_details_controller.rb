class BlobDetailsController < ApplicationController
  def show
    @blob = ActiveStorage::Blob.associated_with_user(current_user.id)
                               .find(params[:active_storage_blob_id])
    respond_to(&:html)
  end
end
