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

ActiveRecord::Schema.define(version: 20161108153147) do

  create_table "extracts", force: :cascade do |t|
    t.string   "generated_id"
    t.text     "name"
    t.string   "blacklab_pid"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "nested_metadata_boolean_values", force: :cascade do |t|
    t.boolean  "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nested_metadata_date_values", force: :cascade do |t|
    t.date     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nested_metadata_float_values", force: :cascade do |t|
    t.float    "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nested_metadata_integer_values", force: :cascade do |t|
    t.integer  "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nested_metadata_locations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.string   "content"
    t.string   "toponym"
    t.string   "country"
    t.integer  "geonames_id", limit: 8
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "nested_metadata_metadata_groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "metadata_group_id"
    t.boolean  "group_keys_into_entity", default: false, null: false
    t.boolean  "requires_attachment",    default: false, null: false
    t.integer  "attachment_type",        default: 0,     null: false
    t.string   "attachment_extension"
    t.boolean  "editable_when_locked",   default: false, null: false
    t.integer  "sort_order",             default: 0,     null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "nested_metadata_metadata_groups", ["metadata_group_id"], name: "index_nested_metadata_metadata_groups_on_metadata_group_id"

  create_table "nested_metadata_metadata_keys", force: :cascade do |t|
    t.string   "name"
    t.integer  "metadata_group_id"
    t.integer  "preferred_value_type", default: 5,     null: false
    t.boolean  "editable",             default: true,  null: false
    t.boolean  "filterable",           default: false, null: false
    t.integer  "filter_type",          default: 0,     null: false
    t.integer  "sort_order",           default: 0,     null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "nested_metadata_metadata_keys", ["metadata_group_id"], name: "index_nested_metadata_metadata_keys_on_metadata_group_id"

  create_table "nested_metadata_metadatum_values", force: :cascade do |t|
    t.integer  "metadata_key_id"
    t.integer  "value_id"
    t.string   "value_type"
    t.string   "content"
    t.integer  "group_entity_id", default: 0, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "nested_metadata_source_documents", force: :cascade do |t|
    t.integer  "metadatum_value_id"
    t.integer  "source_document_id"
    t.string   "source_document_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nested_metadata_source_documents", ["metadatum_value_id", "source_document_id"], name: "index_values_documents"
  add_index "nested_metadata_source_documents", ["source_document_id", "metadatum_value_id"], name: "index_documents_values"
  add_index "nested_metadata_source_documents", ["source_document_id", "source_document_type"], name: "index_documents_types"

  create_table "nested_metadata_string_values", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "source_documents_document_locks", force: :cascade do |t|
    t.integer  "source_document_id"
    t.string   "source_document_type"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "source_documents_document_locks", ["source_document_id", "source_document_type"], name: "locked_documents"

  create_table "taalmonsters_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "role"
  end

  add_index "taalmonsters_users", ["email"], name: "index_taalmonsters_users_on_email", unique: true
  add_index "taalmonsters_users", ["reset_password_token"], name: "index_taalmonsters_users_on_reset_password_token", unique: true

end
