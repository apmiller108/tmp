class AddMarkdownFormatToGenerateTextRequests < ActiveRecord::Migration[7.2]
  def change
    add_column :generate_text_requests, :markdown_format, :boolean, null: false, default: true
  end
end
