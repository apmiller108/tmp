class DropConversationIdFromRequests < ActiveRecord::Migration[7.2]
  def change
    remove_reference :generate_text_requests, :conversation, foreign_key: true
    remove_reference :generate_image_requests, :conversation, foreign_key: true
  end
end
