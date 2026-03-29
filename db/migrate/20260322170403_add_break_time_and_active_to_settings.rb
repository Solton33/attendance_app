class AddBreakTimeAndActiveToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :break_time, :integer, null: false, default: 0
    add_column :settings, :active, :boolean, null: false, default: false
  end
end
