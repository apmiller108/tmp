class UpdateTranscriptionJob < ActiveRecord::Migration[7.1]
  def up
    rename_column :transcription_jobs, :vendor_job_id, :remote_job_id
    add_index :transcription_jobs, :status
  end

  def down
    rename_column :transcription_jobs, :remote_job_id, :vendor_job_id
    remove_index :transcription_jobs, :status
  end
end
