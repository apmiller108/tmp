class AddStatusToGenerateImageRequests < ActiveRecord::Migration[7.2]
  def up
    add_column :generate_image_requests, :status, :text

    add_check_constraint :generate_image_requests, "status in ('created', 'queued', 'in_progress', 'failed', 'completed')", name: 'status_check'

    ActiveRecord::Base.connection.execute(<<~SQL)
      UPDATE generate_image_requests
      SET status = 'completed'
    SQL

    change_column_null :generate_image_requests, :status, false
  end

  def down
    remove_check_constraint :generate_image_requests, name: 'status_check'
    remove_column :generate_image_requests, :status
  end
end
