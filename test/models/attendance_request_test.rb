require "test_helper"

class AttendanceRequestTest < ActiveSupport::TestCase
  setup do
    setting = Setting.create!(
      default_start_time: "09:00",
      default_end_time: "18:00",
      break_time: 60,
      active: true
    )

    @attendance = Attendance.create!(
      setting: setting,
      work_date: Date.new(2026, 10, 1),
      start_time: Time.zone.parse("2026-10-01 09:00"),
      end_time: Time.zone.parse("2026-10-01 18:00"),
      break_minutes: 60,
      work_minutes: 480
    )

    @valid_attributes = {
      attendance: @attendance,
      target_date: Date.new(2026, 10, 1),
      reason: "修正申請"
    }
  end

  test "修正項目がすべて未入力の場合は無効" do
    request = AttendanceRequest.new(@valid_attributes)

    assert_not request.valid?
  end

  test "休憩時間を0分に変更する申請は有効" do
    request = AttendanceRequest.new(
      @valid_attributes.merge(requested_break_minutes: 0)
    )

    assert request.valid?, request.errors.full_messages.inspect
  end

  test "修正理由が未入力の場合は無効" do
    request = AttendanceRequest.new(
      @valid_attributes.merge(reason: nil, requested_start_time: Time.zone.parse("2026-10-01 10:00"))
    )

    assert_not request.valid?
  end

  test "対象日が未入力の場合は無効" do
    request = AttendanceRequest.new(
      @valid_attributes.merge(target_date: nil, requested_start_time: Time.zone.parse("2026-10-01 10:00"))
    )

    assert_not request.valid?
  end
end
