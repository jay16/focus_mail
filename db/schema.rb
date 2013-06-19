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

ActiveRecord::Schema.define(:version => 20121023123018) do

  create_table "action_logs", :force => true do |t|
    t.string   "action_name"
    t.integer  "user_id"
    t.datetime "action_datetime"
    t.integer  "asset_id"
    t.string   "asset_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "campaign_entries", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "entry_id"
    t.string   "value"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "campaign_lists", :force => true do |t|
    t.integer  "campaign_id"
    t.string   "list_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.string   "from_name"
    t.string   "from_email"
    t.string   "subject"
    t.integer  "template_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "from_time"
  end

  create_table "categories", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cemail_logs", :force => true do |t|
    t.integer  "template_id"
    t.string   "from_email"
    t.string   "to_eamil"
    t.string   "subject"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "campaign_id"
  end

  create_table "clicks", :force => true do |t|
    t.integer  "member_id"
    t.integer  "campaign_id"
    t.integer  "link_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "entries", :force => true do |t|
    t.integer  "template_id"
    t.string   "name"
    t.string   "default_value"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "links", :force => true do |t|
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lists_members", :force => true do |t|
    t.integer  "list_id"
    t.integer  "member_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "week_number", :default => 3
  end

  create_table "member_org_objects", :force => true do |t|
    t.integer  "member_org_id"
    t.integer  "list_member_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "member_orgs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "members", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "week_number"
    t.integer  "type_email",  :default => 1
  end

  create_table "send_states", :force => true do |t|
    t.integer  "total_address_number"
    t.integer  "effective_operand_address"
    t.integer  "has_sent_number"
    t.float    "send_ratio"
    t.integer  "reach_number"
    t.float    "reach_ratio"
    t.integer  "open_number"
    t.float    "open_ratio"
    t.integer  "be_hits_number"
    t.float    "be_hits_ratio"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "campaign_id"
  end

  create_table "sendmail_log_numbers", :force => true do |t|
    t.integer  "number_log"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sendmail_logs", :force => true do |t|
    t.datetime "send_date"
    t.string   "course_id"
    t.string   "type_email"
    t.string   "from_email"
    t.string   "to_email"
    t.string   "title_email"
    t.string   "tf_email"
    t.string   "test1"
    t.string   "test2"
    t.string   "coding_email"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "campaign_id"
  end

  create_table "templates", :force => true do |t|
    t.string   "name"
    t.string   "file_name"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "img_url",                   :default => 2
    t.string   "zip_url",    :limit => 100
    t.string   "zip_name",   :limit => 100
    t.float    "grade"
  end

  create_table "tracks", :force => true do |t|
    t.integer  "member_id"
    t.integer  "campaign_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_org_objects", :force => true do |t|
    t.integer  "user_org_id"
    t.integer  "asset_id"
    t.string   "asset_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "user_orgs", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "useradmins", :force => true do |t|
    t.integer  "type_user"
    t.integer  "asset_id"
    t.string   "asset_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
