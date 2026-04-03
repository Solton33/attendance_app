class ChangeStartTimeandEndTimeToDatetimeInAttendances < ActiveRecord::Migration[8.1]
  def up
    change_column :attendances, :start_time, :datetime
    change_column :attendances, :end_time, :datetime
    change_column :settings, :default_start_time, :datetime
    change_column :settings, :default_end_time, :datetime

  end

  def down
    change_column :attendances, :start_time, :time
    change_column :attendances, :end_time, :time
    change_column :settings, :default_start_time, :time
    change_column :settings, :default_end_time, :time
  end
end
