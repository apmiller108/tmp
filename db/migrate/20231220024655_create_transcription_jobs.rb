class CreateTranscriptionJobs < ActiveRecord::Migration[7.1]
  def change
    create_table :transcription_jobs do |t|
      t.text :status, null: false
      t.check_constraint "status in ('created', 'queued', 'in_progress', 'failed', 'completed')", name: 'status_check'
      t.jsonb :response
      t.jsonb :request
      t.references :active_storage_blob, null: false, foreign_key: true

      t.timestamps
    end
  end
end
