class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.date :work_date
      t.time :start_time
      t.time :end_time
      t.integer :break_minutes
      t.integer :work_minutes
      t.references :setting, null: false, foreign_key: true

      t.timestamps
    end
  end
end
