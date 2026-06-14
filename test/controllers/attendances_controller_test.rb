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

  ##### 打刻テスト ###################################################################################

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


  ##### デフォルト設定 ###################################################################################
  def create_setting(param = {})
    Setting.create!({
      active: true,
      default_start_time: Time.current.change(hour: 8, min: 30),
      default_end_time: Time.current.change(hour: 17, min: 30),
      break_time: 60}.merge(param))
  end

end
