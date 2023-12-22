class AddVendorJobIdToTranscriptionJob < ActiveRecord::Migration[7.1]
  def change
    add_column :transcription_jobs, :vendor_job_id, :string, limit: 200, null: false
  end
end
