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

ActiveRecord::Schema[7.0].define(version: 2022_07_06_111524) do
  create_table "notes", charset: "utf8mb4", force: :cascade do |t|
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

  create_table "permalinks", charset: "utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "scope", null: false
    t.text "search_request", null: false
    t.datetime "last_resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_permalinks_on_key", unique: true
    t.index ["scope"], name: "index_permalinks_on_scope"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "ils_primary_id", null: false
    t.string "api_key"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "password_reset_token"
    t.timestamp "password_reset_token_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_group_code"
    t.string "user_group_label"
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["ils_primary_id"], name: "index_users_on_ils_primary_id", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
  end

  create_table "watch_list_entries", charset: "utf8mb4", force: :cascade do |t|
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

  create_table "watch_lists", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watch_lists_on_user_id"
  end

  add_foreign_key "notes", "users"
  add_foreign_key "watch_list_entries", "watch_lists"
  add_foreign_key "watch_lists", "users"
end
