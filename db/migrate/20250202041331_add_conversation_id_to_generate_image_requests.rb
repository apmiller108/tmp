class AddConversationIdToGenerateImageRequests < ActiveRecord::Migration[7.2]
  def change
    add_reference :generate_image_requests, :conversation, null: true, foreign_key: true
  end
end
