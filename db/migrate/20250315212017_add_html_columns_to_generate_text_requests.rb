class AddHtmlColumnsToGenerateTextRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :generate_text_requests, :prompt_html, :text
    add_column :generate_text_requests, :assistant_response_html, :text
  end
end
