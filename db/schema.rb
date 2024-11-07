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

ActiveRecord::Schema[7.2].define(version: 2024_11_05_075148) do
  create_table "admin_global_messages", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.string "style", default: "info", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "scope", null: false
    t.string "record_id", null: false
    t.boolean "record_id_migrated", default: false, null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_id"], name: "index_notes_on_record_id"
    t.index ["scope"], name: "index_notes_on_scope"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "permalinks", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "scope", null: false
    t.text "search_request", null: false
    t.datetime "last_resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_permalinks_on_key", unique: true
    t.index ["scope"], name: "index_permalinks_on_scope"
  end

  create_table "proxy_users", charset: "utf8mb4", collation: "utf8mb4_uca1400_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "proxy_user_id", null: false
    t.string "note"
    t.date "expired_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proxy_user_id"], name: "index_proxy_users_on_proxy_user_id"
    t.index ["user_id", "proxy_user_id"], name: "index_proxy_users_on_user_id_and_proxy_user_id", unique: true
    t.index ["user_id"], name: "index_proxy_users_on_user_id"
  end

  create_table "registration_requests", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "token"
    t.string "email"
    t.string "user_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_registration_requests_on_token", unique: true
  end

  create_table "registrations", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "user_group"
    t.string "academic_title"
    t.string "gender"
    t.string "firstname"
    t.string "lastname"
    t.date "birthdate"
    t.string "email"
    t.string "street_address"
    t.string "zip_code"
    t.string "city"
    t.string "street_address2"
    t.string "zip_code2"
    t.string "city2"
    t.boolean "terms_of_use", default: false, null: false
    t.boolean "created_in_alma", default: false, null: false
    t.string "alma_primary_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "ils_primary_id", null: false
    t.string "api_key"
    t.string "password_reset_token"
    t.timestamp "password_reset_token_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.timestamp "activated_at"
    t.string "activation_token"
    t.timestamp "activation_token_created_at"
    t.string "activation_code"
    t.index ["activation_code"], name: "index_users_on_activation_code", unique: true
    t.index ["activation_token"], name: "index_users_on_activation_token", unique: true
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["ils_primary_id"], name: "index_users_on_ils_primary_id", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
  end

  create_table "watch_list_entries", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "watch_list_id", null: false
    t.string "scope", null: false
    t.string "record_id", null: false
    t.boolean "record_id_migrated", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_id"], name: "index_watch_list_entries_on_record_id"
    t.index ["scope"], name: "index_watch_list_entries_on_scope"
    t.index ["watch_list_id"], name: "index_watch_list_entries_on_watch_list_id"
  end

  create_table "watch_lists", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watch_lists_on_user_id"
  end

  add_foreign_key "notes", "users"
  add_foreign_key "proxy_users", "users"
  add_foreign_key "proxy_users", "users", column: "proxy_user_id"
  add_foreign_key "watch_list_entries", "watch_lists"
  add_foreign_key "watch_lists", "users"
end
