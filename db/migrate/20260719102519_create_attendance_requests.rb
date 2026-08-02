class CreateAttendanceRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :attendance_requests do |t|
      t.datetime :requested_at, null: false
      t.date :target_date
      t.references :attendance, foreign_key: true, null: false
      t.datetime :requested_start_time
      t.datetime :requested_end_time
      t.integer :requested_break_minutes
      t.text :reason, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
