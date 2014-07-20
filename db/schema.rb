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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20141027174049) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "attachments", :force => true do |t|
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "template_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "filters", :force => true do |t|
    t.integer  "trigger_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "import_details", :force => true do |t|
    t.integer  "value"
    t.integer  "import_id"
    t.string   "type"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "imports", :force => true do |t|
    t.string   "type"
    t.integer  "local_account_id"
    t.string   "status"
    t.text     "headers"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size"
    t.datetime "csv_file_updated_at"
  end

  create_table "lists", :force => true do |t|
    t.string   "api_id"
    t.integer  "mailchimp_id"
    t.string   "name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "mailchimp_integrations", :force => true do |t|
    t.integer  "local_account_id"
    t.string   "api_key"
    t.string   "students_list_id"
    t.string   "p_former_students_list_id"
    t.string   "p_prospects_list_id"
    t.string   "p_nonstudents_list_id"
    t.string   "all_nonstudents_list_id"
    t.string   "all_list_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "mailchimps", :force => true do |t|
    t.string   "api_key"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "local_account_id"
    t.integer  "primary_list_id"
  end

  create_table "mercury_images", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "scheduled_mails", :force => true do |t|
    t.integer  "template_id"
    t.integer  "local_account_id"
    t.string   "recipient_email"
    t.datetime "send_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "delivered_at"
    t.string   "contact_id"
    t.string   "username"
    t.text     "data"
    t.string   "event_key"
  end

  create_table "segments", :force => true do |t|
    t.text     "query"
    t.string   "api_id"
    t.integer  "list_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "subject"
    t.text     "content"
    t.integer  "local_account_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "templates_triggers", :force => true do |t|
    t.integer "template_id"
    t.integer "trigger_id"
    t.integer "offset_number"
    t.string  "offset_reference"
    t.string  "offset_unit"
  end

  create_table "triggers", :force => true do |t|
    t.string   "event_name"
    t.integer  "local_account_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "current_account_id"
  end

end
