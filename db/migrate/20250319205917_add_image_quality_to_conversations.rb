class AddImageQualityToConversations < ActiveRecord::Migration[8.0]
  def change
    add_column :conversations, :image_quality, :text, default: 'standard'
    add_check_constraint :conversations, "image_quality in ('standard', 'high')"
    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE conversations SET image_quality = 'standard'
    SQL
  end
end
