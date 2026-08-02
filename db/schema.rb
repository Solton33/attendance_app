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

ActiveRecord::Schema[8.1].define(version: 2026_07_19_102519) do
  create_table "attendance_requests", force: :cascade do |t|
    t.integer "attendance_id", null: false
    t.datetime "created_at", null: false
    t.text "reason", null: false
    t.datetime "requested_at", null: false
    t.integer "requested_break_minutes"
    t.datetime "requested_end_time"
    t.datetime "requested_start_time"
    t.integer "status", default: 0, null: false
    t.date "target_date"
    t.datetime "updated_at", null: false
    t.index ["attendance_id"], name: "index_attendance_requests_on_attendance_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "break_minutes"
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.integer "setting_id", null: false
    t.datetime "start_time"
    t.datetime "updated_at", null: false
    t.date "work_date"
    t.integer "work_minutes"
    t.index ["setting_id"], name: "index_attendances_on_setting_id"
  end

  create_table "settings", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.integer "break_time", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "default_end_time"
    t.datetime "default_start_time"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "attendance_requests", "attendances"
  add_foreign_key "attendances", "settings"
end
