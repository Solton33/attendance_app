require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  ################## 正常テスト ##################
  # 勤務時間計算テスト
  test "勤務時間計算" do
    attendance = @attendance

    attendance.break_minutes = 60
    result = attendance.calc_work_minutes

    assert_equal 480, result
  end

  # 出勤打刻テスト
  test "出勤打刻(clock_in)" do
    attendance = Attendance.new(
      work_date: Date.current,
      start_time: nil,
      end_time: nil
    )

    setting = Setting.create(
      break_time: 60
    )

    now = Time.current

    warning, message, result = attendance.clock_in(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages

    assert_equal now, attendance.start_time
    assert_equal setting.break_time, attendance.break_minutes
    assert_nil warning
    assert_equal "出勤時刻を打刻しました", message
    assert_equal true, result
  end


  ################## 異常テスト ##################
  # バリデーションテスト
  test "打刻時間が出勤 > 退勤時のバリデーション" do
    attendance = Attendance.new(
      start_time: Time.current.change(hour: 18, min: 00),
      end_time: Time.current.change(hour: 9, min: 00),
      break_minutes: 60
    )

    result = attendance.valid?

    assert_not result
  end




  setup do
    # 正常テスト
    @attendance = Attendance.new(
      start_time: Time.current.change(hour: 8, min: 30),
      end_time: Time.current.change(hour: 17, min: 30)
    )

    @setting = Setting.new(
      break_time: 60
    )
  end
end
