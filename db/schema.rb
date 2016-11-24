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

ActiveRecord::Schema.define(version: 20161124104139) do

  create_table "extracts", force: :cascade do |t|
    t.string   "generated_id", limit: 255
    t.text     "name",         limit: 65535
    t.string   "blacklab_pid", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
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
    t.float    "content",    limit: 24
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "nested_metadata_integer_values", force: :cascade do |t|
    t.integer  "content",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "nested_metadata_locations", force: :cascade do |t|
    t.float    "latitude",    limit: 24
    t.float    "longitude",   limit: 24
    t.string   "content",     limit: 255
    t.string   "toponym",     limit: 255
    t.string   "country",     limit: 255
    t.integer  "geonames_id", limit: 8
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "nested_metadata_metadata_groups", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.integer  "metadata_group_id",      limit: 4
    t.boolean  "group_keys_into_entity",             default: false, null: false
    t.boolean  "requires_attachment",                default: false, null: false
    t.integer  "attachment_type",        limit: 4,   default: 0,     null: false
    t.string   "attachment_extension",   limit: 255
    t.boolean  "editable_when_locked",               default: false, null: false
    t.integer  "sort_order",             limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "nested_metadata_metadata_groups", ["metadata_group_id"], name: "index_nested_metadata_metadata_groups_on_metadata_group_id", using: :btree

  create_table "nested_metadata_metadata_keys", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.integer  "metadata_group_id",    limit: 4
    t.integer  "preferred_value_type", limit: 4,   default: 5,     null: false
    t.boolean  "editable",                         default: true,  null: false
    t.boolean  "filterable",                       default: false, null: false
    t.integer  "filter_type",          limit: 4,   default: 0,     null: false
    t.integer  "sort_order",           limit: 4,   default: 0,     null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "nested_metadata_metadata_keys", ["metadata_group_id"], name: "index_nested_metadata_metadata_keys_on_metadata_group_id", using: :btree

  create_table "nested_metadata_metadatum_values", force: :cascade do |t|
    t.integer  "metadata_key_id", limit: 4
    t.integer  "value_id",        limit: 4
    t.string   "value_type",      limit: 255
    t.string   "content",         limit: 255
    t.integer  "group_entity_id", limit: 4,   default: 0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "nested_metadata_metadatum_values", ["metadata_key_id"], name: "index_nested_metadata_metadatum_values_on_metadata_key_id", using: :btree

  create_table "nested_metadata_source_documents", force: :cascade do |t|
    t.integer  "metadatum_value_id",   limit: 4
    t.integer  "source_document_id",   limit: 4
    t.string   "source_document_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "nested_metadata_source_documents", ["metadatum_value_id", "source_document_id"], name: "index_values_documents", using: :btree
  add_index "nested_metadata_source_documents", ["source_document_id", "metadatum_value_id"], name: "index_documents_values", using: :btree
  add_index "nested_metadata_source_documents", ["source_document_id", "source_document_type"], name: "index_documents_types", using: :btree

  create_table "nested_metadata_string_values", force: :cascade do |t|
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "source_documents_document_locks", force: :cascade do |t|
    t.integer  "source_document_id",   limit: 4
    t.string   "source_document_type", limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "source_documents_document_locks", ["source_document_id", "source_document_type"], name: "locked_documents", using: :btree

  create_table "taalmonsters_users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name",                   limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "role",                   limit: 4
  end

  add_index "taalmonsters_users", ["email"], name: "index_taalmonsters_users_on_email", unique: true, using: :btree
  add_index "taalmonsters_users", ["reset_password_token"], name: "index_taalmonsters_users_on_reset_password_token", unique: true, using: :btree

end
