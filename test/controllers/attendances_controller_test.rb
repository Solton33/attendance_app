require "test_helper"

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  ##### 表示テスト ###################################################################################
  test "home画面表示" do
    get root_path

    assert_response :success
  end

  test "一覧画面表示" do
    get attendances_path

    assert_response :success
  end

  test "設置画面表示" do
    get setting_path

    assert_response :success
  end

  ##### 正常テスト ###################################################################################

  test "出勤打刻処理" do
    post clock_in_attendances_path

    attendance = Attendance.find_by(work_date: Date.current)

    p response.redirect_url
    p flash[:notice]
    p attendance.attributes

    assert_redirected_to root_path
    assert_not_nil attendance.start_time
    assert_equal "出勤時刻を打刻しました", flash[:notice]
  end

  test "退勤打刻処理" do
    post clock_out_attendances_path

    attendance = Attendance.find_by(work_date: Date.current)

    p response.redirect_url
    p flash[:notice]
    p attendance.attributes

    assert_redirected_to root_path
    assert_not_nil attendance.end_time
    assert_equal "退勤打刻を打刻しました", flash[:notice]
  end

  test "定時出勤打刻処理" do
    create_setting

    travel_to Time.current.change(hour: 8, min: 30) do
      post setting_clock_in_attendances_path

      attendance = Attendance.find_by(work_date: Date.current)
      setting = Setting.find_by(active: true)

      p response.redirect_url
      p flash[:notice]
      p attendance.attributes
      p setting.attributes

      assert_redirected_to root_path
      assert_not_nil attendance.start_time
      assert_equal "出勤時刻を打刻しました", flash[:notice]
    end
  end

  test "定時退勤打刻処理" do
    create_setting

    travel_to Time.current.change(hour: 17, min: 30) do
      post setting_clock_out_attendances_path

      attendance = Attendance.find_by(work_date: Date.current)
      setting = Setting.find_by(active: true)

      p response.redirect_url
      p flash[:notice]
      p attendance.attributes
      p setting.attributes

      assert_redirected_to root_path
      assert_not_nil attendance.end_time
      assert_equal "退勤時刻を打刻しました", flash[:notice]
    end
  end

  ##### 異常テスト ###################################################################################

  test "出勤打刻処理_出勤済み" do
    create_setting
    attendance = create_attendance(
      start_time: Time.current.change(hour: 8, min: 30)
    )

    post clock_in_attendances_path

    p response.redirect_url
    p flash[:alert]
    p attendance.attributes

    assert_redirected_to root_path
    assert_equal "出勤打刻は打刻済みです", flash[:alert]
    assert_equal 8, attendance.start_time.hour
    assert_equal 30, attendance.start_time.min
  end

  test "退勤打刻処理_退勤済み" do
    create_setting
    attendance = create_attendance(
      start_time: Time.current.change(hour: 8, min: 30),
      end_time: Time.current.change(hour: 17, min: 30)
    )

    post clock_out_attendances_path

    p response.redirect_url
    p flash[:alert]
    p attendance.attributes

    assert_redirected_to root_path
    assert_equal "退勤時刻は打刻済みです", flash[:alert]
    assert_equal 17, attendance.end_time.hour
    assert_equal 30, attendance.end_time.min
  end

  test "定時出勤打刻処理_出勤済み" do
    create_setting
    attendance = create_attendance(
      start_time: Time.current.change(hour: 8, min: 00)
    )

    travel_to Time.current.change(hour: 8, min: 25) do
      post setting_clock_in_attendances_path

      p response.redirect_url
      p flash[:alert]
      p attendance.attributes

      assert_redirected_to root_path
      assert_equal "出勤打刻は打刻済みです", flash[:alert]
      assert_equal 8, attendance.start_time.hour
      assert_equal 0, attendance.start_time.min
    end
  end

  test "定時退勤打刻処理_退勤済み" do
    create_setting
    attendance = create_attendance(
      start_time: Time.current.change(hour: 8, min: 30),
      end_time: Time.current.change(hour: 17, min: 30)
    )

    travel_to Time.current.change(hour: 17, min: 35) do
      post setting_clock_out_attendances_path

      p response.redirect_url
      p flash[:alert]
      p attendance.attributes

      assert_redirected_to root_path
      assert_equal "退勤打刻は打刻済みです", flash[:alert]
      assert_equal 17, attendance.end_time.hour
      assert_equal 30, attendance.end_time.min
    end
  end

  test "定時出勤打刻処理_設定なし" do
    create_setting(
      default_start_time: nil,
      default_end_time: nil
    )

    attendance = create_attendance

    travel_to Time.current.change(hour: 8, min: 25) do
      post setting_clock_in_attendances_path

      p response.redirect_url
      p flash[:alert]
      p attendance.attributes

      assert_redirected_to root_path
      assert_equal "定時出勤が未設定です", flash[:alert]
      assert_nil attendance.start_time
    end
  end

  test "定時退勤打刻処理_設定なし" do
    create_setting(
      default_start_time: nil,
      default_end_time: nil
    )

    attendance = create_attendance(
      start_time: Time.current.change(hour: 8, min: 30)
  )

    travel_to Time.current.change(hour: 17, min: 35) do
      post setting_clock_out_attendances_path

      p response.redirect_url
      p flash[:alert]
      p attendance.attributes

      assert_redirected_to root_path
      assert_equal "定時退勤が未設定です", flash[:alert]
      assert_nil attendance.end_time
    end
  end


  ##### デフォルト設定 ###################################################################################
  def create_attendance(param = {})
    Attendance.create!({
      work_date: Date.current,
      start_time: nil,
      end_time: nil,
      setting_id: 1 }.merge(param))
  end


  def create_setting(param = {})
    Setting.create!({
      id: 1,
      active: true,
      default_start_time: Time.current.change(hour: 8, min: 30),
      default_end_time: Time.current.change(hour: 17, min: 30),
      break_time: 60 }.merge(param))
  end
end
