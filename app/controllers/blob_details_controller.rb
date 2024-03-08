class BlobDetailsController < ApplicationController
  def show
    @blob = ActiveStorage::Blob.joins(:memo)
                               .where(memo: { user_id: current_user.id })
                               .find(params[:active_storage_blob_id])
    respond_to(&:html)
  end
end
