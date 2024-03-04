class BlobDetailsController < ApplicationController
  def show
    blob = ActiveStorage::Blob.find(params[:active_storage_blob_id])
    render inline: helpers.turbo_frame_tag("#{helpers.dom_id(blob)}_blob_details") { blob.generate_image_request.parameterize.to_s }
  end
end
