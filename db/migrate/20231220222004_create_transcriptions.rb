class CreateTranscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :transcriptions do |t|
      t.text :content, null: false
      t.references :active_storage_blob, null: false, foreign_key: true
      t.references :transcription_job, null: false, foreign_key: true

      t.timestamps
    end
  end
end
