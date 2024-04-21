class AddIndexToGenerateTextRequests < ActiveRecord::Migration[7.1]
  def change
    add_index :generate_text_requests, [:user_id, :text_id], unique: true
  end
end
