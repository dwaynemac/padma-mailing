# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200219185054) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conditions", force: :cascade do |t|
    t.string   "key"
    t.string   "value"
    t.integer  "trigger_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "filters", force: :cascade do |t|
    t.integer  "trigger_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_details", force: :cascade do |t|
    t.integer  "value"
    t.integer  "import_id"
    t.string   "type"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", force: :cascade do |t|
    t.string   "type"
    t.integer  "local_account_id"
    t.string   "status"
    t.text     "headers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size",    limit: 8
    t.datetime "csv_file_updated_at"
  end

  create_table "mailchimp_configurations", force: :cascade do |t|
    t.string   "api_key"
    t.integer  "local_account_id"
    t.integer  "primary_list_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "synchronizer_id"
    t.string   "filter_method"
    t.string   "petal_subscription_id"
  end

  create_table "mailchimp_lists", force: :cascade do |t|
    t.string   "api_id"
    t.integer  "mailchimp_configuration_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_attributes"
    t.boolean  "receive_notifications",      default: true
    t.text     "webhook_configuration"
  end

  create_table "mailchimp_segments", force: :cascade do |t|
    t.string   "api_id"
    t.integer  "mailchimp_list_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "student"
    t.boolean  "exstudent"
    t.boolean  "prospect"
    t.string   "coefficient"
    t.boolean  "only_man"
    t.string   "contact_segment_id"
    t.string   "gender"
    t.string   "followed_by"
  end

  create_table "mercury_images", force: :cascade do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scheduled_mails", force: :cascade do |t|
    t.integer  "template_id"
    t.integer  "local_account_id"
    t.string   "recipient_email"
    t.datetime "send_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "delivered_at"
    t.string   "contact_id"
    t.string   "username"
    t.text     "data"
    t.string   "event_key"
    t.string   "from_display_name"
    t.string   "from_email_address"
    t.string   "bccs"
    t.text     "conditions"
    t.boolean  "cancelled",          default: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "templates", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "subject"
    t.text     "content"
    t.integer  "local_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_templates_folder_id"
  end

  create_table "templates_folders", force: :cascade do |t|
    t.integer  "local_account_id"
    t.integer  "parent_templates_folder_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "templates_triggers", force: :cascade do |t|
    t.integer "template_id"
    t.integer "trigger_id"
    t.integer "offset_number"
    t.string  "offset_reference"
    t.string  "offset_unit"
    t.string  "from_display_name"
    t.string  "from_email_address"
    t.string  "bccs"
  end

  create_table "triggers", force: :cascade do |t|
    t.string   "event_name"
    t.integer  "local_account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "current_account_id"
  end

end
