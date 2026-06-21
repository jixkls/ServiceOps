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

ActiveRecord::Schema[8.1].define(version: 2026_06_21_171317) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "document"
    t.string "email"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
  end

  create_table "diagnostics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "service_order_id", null: false
    t.string "summary"
    t.text "technical_details"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["service_order_id"], name: "index_diagnostics_on_service_order_id", unique: true
    t.index ["user_id"], name: "index_diagnostics_on_user_id"
  end

  create_table "service_categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "service_orders", force: :cascade do |t|
    t.bigint "assigned_user_id"
    t.string "code"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "description"
    t.datetime "finished_at"
    t.datetime "opened_at"
    t.string "priority"
    t.string "public_token"
    t.bigint "service_category_id", null: false
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_service_orders_on_assigned_user_id"
    t.index ["code"], name: "index_service_orders_on_code", unique: true
    t.index ["customer_id"], name: "index_service_orders_on_customer_id"
    t.index ["public_token"], name: "index_service_orders_on_public_token", unique: true
    t.index ["service_category_id"], name: "index_service_orders_on_service_category_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "role", default: "attendant", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "diagnostics", "service_orders"
  add_foreign_key "diagnostics", "users"
  add_foreign_key "service_orders", "customers"
  add_foreign_key "service_orders", "service_categories"
  add_foreign_key "service_orders", "users", column: "assigned_user_id"
  add_foreign_key "sessions", "users"
end
