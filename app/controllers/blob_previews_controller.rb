class BlobPreviewsController < ApplicationController
  def show
    @blob = ActiveStorage::Blob.joins(:memo)
                               .where(memo: { user_id: current_user.id })
                               .find(params[:active_storage_blob_id])

    render inline: "<turbo-frame id='#{AttachmentIconComponent.turbo_frame_id(@blob.id)}'>#{@blob.filename}</turbo-frame>".html_safe

  end
end
