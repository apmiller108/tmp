# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_01_07_003530) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["content_type"], name: "index_active_storage_blobs_on_content_type", opclass: :gin_trgm_ops, using: :gin
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "memos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_memos_on_user_id"
  end

  create_table "summaries", force: :cascade do |t|
    t.string "summarizable_type", null: false
    t.bigint "summarizable_id", null: false
    t.text "content"
    t.text "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["summarizable_type", "summarizable_id"], name: "index_summaries_on_summarizable"
    t.check_constraint "status = ANY (ARRAY['created'::text, 'queued'::text, 'in_progress'::text, 'failed'::text, 'completed'::text])", name: "status_check"
  end

  create_table "transcription_jobs", force: :cascade do |t|
    t.text "status", null: false
    t.jsonb "response"
    t.jsonb "request"
    t.bigint "active_storage_blob_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remote_job_id", limit: 200, null: false
    t.index ["active_storage_blob_id"], name: "index_transcription_jobs_on_active_storage_blob_id"
    t.index ["status"], name: "index_transcription_jobs_on_status"
    t.check_constraint "status = ANY (ARRAY['created'::text, 'queued'::text, 'in_progress'::text, 'failed'::text, 'completed'::text])", name: "status_check"
  end

  create_table "transcriptions", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "active_storage_blob_id", null: false
    t.bigint "transcription_job_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_storage_blob_id"], name: "index_transcriptions_on_active_storage_blob_id"
    t.index ["transcription_job_id"], name: "index_transcriptions_on_transcription_job_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "provider"
    t.string "uid"
    t.boolean "developer", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "memos", "users", on_delete: :cascade
  add_foreign_key "transcription_jobs", "active_storage_blobs"
  add_foreign_key "transcriptions", "active_storage_blobs"
  add_foreign_key "transcriptions", "transcription_jobs"
end
