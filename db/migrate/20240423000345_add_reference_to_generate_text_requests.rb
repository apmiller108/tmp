class AddReferenceToGenerateTextRequests < ActiveRecord::Migration[7.1]
  def change
    add_reference :generate_text_requests, :conversation, foreign_key: true
  end
end
