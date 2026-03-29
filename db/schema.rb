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

ActiveRecord::Schema[8.1].define(version: 2026_03_22_170403) do
  create_table "attendances", force: :cascade do |t|
    t.integer "break_minutes"
    t.datetime "created_at", null: false
    t.time "end_time"
    t.integer "setting_id", null: false
    t.time "start_time"
    t.datetime "updated_at", null: false
    t.date "work_date"
    t.integer "work_minutes"
    t.index ["setting_id"], name: "index_attendances_on_setting_id"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.integer "break_time", default: 0, null: false
    t.datetime "created_at", null: false
    t.time "default_end_time"
    t.time "default_start_time"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "attendances", "settings"
end
