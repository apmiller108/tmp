class AddModelToGenerateTextRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :generate_text_requests, :model, :string
  end
end
