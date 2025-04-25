class RemoveColumnNullFromGenerateTextRequestsTextId < ActiveRecord::Migration[8.0]
  def change
    change_column_null :generate_text_requests, :text_id, true
  end
end
