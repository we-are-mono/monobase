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

ActiveRecord::Schema[8.1].define(version: 2025_11_11_210222) do
  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hardware_revision"
    t.integer "pcb_version"
    t.string "product_group"
    t.string "product_line"
    t.string "qr1"
    t.string "qr2"
    t.string "serial_number"
    t.datetime "updated_at", null: false
  end

  create_table "macs", force: :cascade do |t|
    t.integer "addr"
    t.datetime "created_at", null: false
    t.integer "device_id"
    t.datetime "updated_at", null: false
    t.index ["device_id"], name: "index_macs_on_device_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["api_key"], name: "index_users_on_api_key", unique: true
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "macs", "devices"
  add_foreign_key "sessions", "users"
end
