class ChangeGenerateTextRequestsModelNotNull < ActiveRecord::Migration[7.2]
  def change
    change_column_null :generate_text_requests, :model, false
  end
end
