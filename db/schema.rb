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

ActiveRecord::Schema[7.2].define(version: 2026_04_24_142816) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "plan_day_id", null: false
    t.integer "overall_score"
    t.integer "energy_level"
    t.integer "hunger_level"
    t.string "mood"
    t.text "free_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_day_id"], name: "index_daily_notes_on_plan_day_id"
    t.index ["user_id", "plan_day_id"], name: "index_daily_notes_on_user_id_and_plan_day_id", unique: true
    t.index ["user_id"], name: "index_daily_notes_on_user_id"
  end

  create_table "meal_items", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.text "description", null: false
    t.string "quantity"
    t.text "swap_options", default: [], null: false, array: true
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_id"], name: "index_meal_items_on_meal_id"
  end

  create_table "meal_logs", force: :cascade do |t|
    t.bigint "meal_id", null: false
    t.integer "status", default: 0, null: false
    t.text "actual_description"
    t.datetime "logged_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_id"], name: "index_meal_logs_on_meal_id", unique: true
  end

  create_table "meal_plans", force: :cascade do |t|
    t.string "name", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "notes"
    t.bigint "owner_id", null: false
    t.bigint "assignee_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_meal_plans_on_assignee_id"
    t.index ["owner_id"], name: "index_meal_plans_on_owner_id"
    t.index ["start_date"], name: "index_meal_plans_on_start_date"
  end

  create_table "meals", force: :cascade do |t|
    t.bigint "plan_day_id", null: false
    t.integer "meal_type", null: false
    t.time "time"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_day_id", "position"], name: "index_meals_on_plan_day_id_and_position"
    t.index ["plan_day_id"], name: "index_meals_on_plan_day_id"
  end

  create_table "plan_days", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_plan_id", "date"], name: "index_plan_days_on_meal_plan_id_and_date", unique: true
    t.index ["meal_plan_id"], name: "index_plan_days_on_meal_plan_id"
  end

  create_table "shopping_list_checks", force: :cascade do |t|
    t.bigint "meal_plan_id", null: false
    t.string "item_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meal_plan_id", "item_key"], name: "index_shopping_list_checks_on_meal_plan_id_and_item_key", unique: true
    t.index ["meal_plan_id"], name: "index_shopping_list_checks_on_meal_plan_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "daily_notes", "plan_days"
  add_foreign_key "daily_notes", "users"
  add_foreign_key "meal_items", "meals"
  add_foreign_key "meal_logs", "meals"
  add_foreign_key "meal_plans", "users", column: "assignee_id"
  add_foreign_key "meal_plans", "users", column: "owner_id"
  add_foreign_key "meals", "plan_days"
  add_foreign_key "plan_days", "meal_plans"
  add_foreign_key "shopping_list_checks", "meal_plans"
end
