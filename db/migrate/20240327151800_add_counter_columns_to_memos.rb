class AddCounterColumnsToMemos < ActiveRecord::Migration[7.1]
  def change
    add_column :memos, :image_attachment_count, :integer, null: false, default: 0
    add_column :memos, :audio_attachment_count, :integer, null: false, default: 0
    add_column :memos, :video_attachment_count, :integer, null: false, default: 0
    add_column :memos, :attachment_count, :integer, null: false, default: 0
  end
end
