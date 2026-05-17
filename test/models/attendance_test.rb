require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  ##### 正常テスト ###################################################################################

  ######### calc_work_minutes #########
  # 勤務時間計算テスト
  test "勤務時間計算" do
    attendance = @attendance

    attendance.break_minutes = 60
    result = attendance.calc_work_minutes

    p attendance
    p result

    assert_equal 480, result
  end

  ######### clock_in #########
  # 出勤打刻テスト
  test "出勤打刻(clock_in)" do
    attendance = Attendance.new(
      work_date: Date.current,
      start_time: nil,
      end_time: nil
    )

    setting = @setting

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


  ######### clock_out #########
  # 退勤打刻テスト
  test "退勤打刻(clock_out)" do
    attendance = @attendance
    attendance.work_date = Date.current
    attendance.end_time = nil

    setting = @setting

    now = Time.current.change(hour: 17, min: 30)

    warning, message, result = attendance.clock_out(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.work_minutes

    assert_equal "退勤打刻を打刻しました", message
    assert_nil warning
    assert_equal true, result
    assert_equal 480, attendance.work_minutes
  end


  ######### clock_in #########
  # 定時出勤打刻テスト
  test "定時出勤打刻(setting_clock_in)" do
    attendance = Attendance.new(
      work_date: Date.current,
      start_time: nil,
      end_time: nil
    )

    setting = Setting.new(
      default_start_time: Time.current.change(hour: 9, min: 0),
      break_time: 60
    )

    now = Time.current.change(hour: 8, min: 30)

    warning, message, result = attendance.setting_clock_in(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.start_time
    p setting.default_start_time

    assert_equal "出勤時刻を打刻しました", message
    assert_nil warning
    assert_equal true, result
    assert_equal setting.default_start_time.hour, attendance.start_time.hour
    assert_equal setting.default_start_time.min, attendance.start_time.min
  end

  # 境界値テスト(定時出勤打刻)
  test "定時出勤打刻(setting_clock_in)_境界値" do
    attendance = Attendance.new(
      work_date: Date.current,
      start_time: nil,
      end_time: nil
    )

    setting = Setting.new(
      default_start_time: Time.current.change(hour: 9, min: 0),
      break_time: 60
    )

    now = Time.current.change(hour: 8, min: 31)

    warning, message, result = attendance.setting_clock_in(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.start_time

    assert_equal "出勤時刻を打刻しました", message
    assert_nil warning
    assert_equal true, result
    assert_equal setting.default_start_time.hour, attendance.start_time.hour
    assert_equal setting.default_start_time.min, attendance.start_time.min
  end


  ##### 準正常テスト ###################################################################################

  ######### clock_out(出勤なし) #########
  # 退勤打刻テスト(出勤打刻なし)
  test "退勤打刻(clock_out)_出勤打刻なし" do
    attendance = Attendance.new(
      work_date: Date.current,
      start_time: nil,
      end_time: nil
    )

    setting = @setting
    now = Time.current.change(hour: 17, min: 30)

    warning, message, result = attendance.clock_out(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.start_time
    p attendance.work_minutes

    assert_equal "出勤打刻がされていません、後ほど修正してください", warning
    assert_equal "退勤打刻を打刻しました", message
    assert_equal true, result
    assert_nil attendance.start_time
    assert_nil attendance.work_minutes
  end

  ##### 異常テスト ###################################################################################

  ######### clock_in #########
  # 出勤打刻テスト(出勤済み)
  test "出勤打刻(clock_in)_出勤済み" do
    attendance = Attendance.new(
      work_date: Date.current,
      start_time: Time.current.change(hour: 8, min: 30),
      end_time: nil
    )

    setting = @setting
    now = Time.current

    warning, message, result = attendance.clock_in(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages

    assert_equal "出勤打刻は打刻済みです", message
    assert_nil warning
    assert_equal false, result
  end

  # 出勤打刻テスト(退勤済み)
  test "出勤打刻(clock_in)_退勤済み" do
    attendance = @attendance
    setting = @setting
    now = Time.current

    warning, message, result = attendance.clock_in(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages

    assert_equal "退勤時刻は打刻済みです", message
    assert_nil warning
    assert_equal false, result
  end

  # save失敗テスト(clock_in)
  test "save失敗(clock_in)" do
    attendance = Attendance.new(
      work_date: nil,
      start_time: nil,
      end_time: nil
    )

    setting = @setting
    now = Time.current

    warning, message, result = attendance.clock_in(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.work_date

    assert_equal "出勤打刻に失敗しました", message
    assert_nil warning
    assert_equal false, result
    assert_nil attendance.work_date
  end



  ######### clock_out #########
  # 退勤打刻テスト(退勤打刻済み)
  test "退勤打刻(clock_out)_退勤済み" do
    attendance = @attendance
    attendance.work_date = Date.current

    setting = @setting
    now = Time.current

    warning, message, result = attendance.clock_out(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.work_minutes

    assert_equal "退勤時刻は打刻済みです", message
    assert_nil warning
    assert_equal false, result
    assert_nil attendance.work_minutes
  end

  # 退勤打刻テスト(退勤時刻 < 出勤時刻)
  test "退勤打刻(clock_out)_退勤時刻 < 出勤時刻" do
    attendance = Attendance.new(
    work_date: Date.current,
    start_time: Time.current.change(hour: 18, min: 00),
    end_time: nil
  )

    setting = @setting
    now = Time.current.change(hour: 17, min: 30)

    warning, message, result = attendance.clock_out(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.work_minutes

    assert_equal "退勤時刻が出勤時刻より前です", message
    assert_nil warning
    assert_equal false, result
    assert_nil attendance.work_minutes
  end


  # save失敗テスト(clock_out)
  test "save失敗(clock_out)" do
    attendance = Attendance.new(
      work_date: nil,
      start_time: Time.current.change(hour: 8, min: 30),
      end_time: nil
    )

    setting = @setting
    now = Time.current.change(hour: 17, min: 30)

    warning, message, result = attendance.clock_out(setting, now)

    p attendance
    p now
    p warning, message, result
    p attendance.errors.full_messages
    p attendance.work_date

    assert_equal "退勤打刻に失敗しました", message
    assert_nil warning
    assert_equal false, result
    assert_nil attendance.work_date
  end







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
