class AddGenerateTextRequestReferenceToGenerateImageRequests < ActiveRecord::Migration[7.2]
  def change
    add_reference :generate_image_requests, :generate_text_request, null: true, foreign_key: true
  end
end
