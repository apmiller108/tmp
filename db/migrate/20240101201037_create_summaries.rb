class CreateSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :summaries do |t|
      t.references :summarizable, polymorphic: true, null: false
      t.text :content
      t.text :status, null: false
      t.check_constraint "status in ('created', 'queued', 'in_progress', 'failed', 'completed')", name: 'status_check'

      t.timestamps
    end
  end
end
