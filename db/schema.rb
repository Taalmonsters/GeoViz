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

ActiveRecord::Schema.define(version: 20170302155458) do

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.string   "request_uuid",    limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "extracts", force: :cascade do |t|
    t.string   "generated_id", limit: 255
    t.text     "name",         limit: 65535
    t.string   "blacklab_pid", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "token_count",  limit: 4
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

  create_table "nested_metadata_entity_mentions", force: :cascade do |t|
    t.string   "entity_type",        limit: 255, default: "undefined", null: false
    t.integer  "metadata_group_id",  limit: 4,                         null: false
    t.integer  "source_document_id", limit: 4,                         null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "nested_metadata_entity_mentions", ["entity_type"], name: "index_nested_metadata_entity_mentions_on_entity_type", using: :btree
  add_index "nested_metadata_entity_mentions", ["metadata_group_id"], name: "index_nested_metadata_entity_mentions_on_metadata_group_id", using: :btree
  add_index "nested_metadata_entity_mentions", ["source_document_id"], name: "index_nested_metadata_entity_mentions_on_source_document_id", using: :btree

  create_table "nested_metadata_float_values", force: :cascade do |t|
    t.decimal  "content",    precision: 16, scale: 6
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "nested_metadata_integer_values", force: :cascade do |t|
    t.integer  "content",    limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "nested_metadata_locations", force: :cascade do |t|
    t.decimal  "latitude",                precision: 9, scale: 6
    t.decimal  "longitude",               precision: 9, scale: 6
    t.string   "content",     limit: 255
    t.string   "toponym",     limit: 255
    t.string   "country",     limit: 255
    t.integer  "geonames_id", limit: 8
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  create_table "nested_metadata_metadata_groups", force: :cascade do |t|
    t.string   "name",                   limit: 255,                      null: false
    t.integer  "metadata_group_id",      limit: 4
    t.boolean  "group_keys_into_entity",             default: false,      null: false
    t.boolean  "requires_attachment",                default: false,      null: false
    t.integer  "attachment_type",        limit: 4,   default: 0,          null: false
    t.string   "attachment_extension",   limit: 255
    t.boolean  "editable_when_locked",               default: false,      null: false
    t.integer  "sort_order",             limit: 4,   default: 0,          null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.string   "entity_mention_type",    limit: 255, default: "location", null: false
  end

  add_index "nested_metadata_metadata_groups", ["metadata_group_id"], name: "index_nested_metadata_metadata_groups_on_metadata_group_id", using: :btree

  create_table "nested_metadata_metadata_keys", force: :cascade do |t|
    t.string   "name",                 limit: 255,                 null: false
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
    t.integer  "metadata_key_id",    limit: 4
    t.integer  "value_id",           limit: 4
    t.string   "value_type",         limit: 255
    t.string   "content",            limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "entity_mention_id",  limit: 4
    t.integer  "source_document_id", limit: 4
  end

  add_index "nested_metadata_metadatum_values", ["entity_mention_id"], name: "index_nested_metadata_metadatum_values_on_entity_mention_id", using: :btree
  add_index "nested_metadata_metadatum_values", ["metadata_key_id"], name: "index_nested_metadata_metadatum_values_on_metadata_key_id", using: :btree
  add_index "nested_metadata_metadatum_values", ["source_document_id"], name: "index_nested_metadata_metadatum_values_on_source_document_id", using: :btree

  create_table "nested_metadata_source_documents", force: :cascade do |t|
    t.integer  "source_document_id",   limit: 4,   null: false
    t.string   "source_document_type", limit: 255, null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "nested_metadata_source_documents", ["source_document_id"], name: "index_nested_metadata_source_documents_on_source_document_id", using: :btree
  add_index "nested_metadata_source_documents", ["source_document_type"], name: "index_nested_metadata_source_documents_on_source_document_type", using: :btree

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
