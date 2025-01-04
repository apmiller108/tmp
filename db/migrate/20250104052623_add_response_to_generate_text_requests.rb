class AddResponseToGenerateTextRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :generate_text_requests, :response, :jsonb, default: {}
  end
end
