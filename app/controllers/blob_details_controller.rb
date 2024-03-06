class BlobDetailsController < ApplicationController
  def show
    @blob = ActiveStorage::Blob.joins(:generate_image_request)
                               .where(generate_image_request: { user_id: current_user.id })
                               .find(params[:active_storage_blob_id])
    respond_to(&:html)
  end
end
