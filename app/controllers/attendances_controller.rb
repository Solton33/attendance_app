class AttendancesController < ApplicationController
  before_action :set_attendance
  before_action :set_setting

  #################### 出退勤時刻の表示 ########################
  def home
  end

  #################### 勤怠一覧の表示 ########################
  def index
    # 表示月をパラメータで取得
    year = params[:year]&.to_i || Date.today.year
    month = params[:month]&.to_i || Date.today.month

    # 表示月の１ヶ月分を取得
    @current_date = Date.new(year, month, 1)
    @dates = (@current_date.beginning_of_month..@current_date.end_of_month).to_a
    @attendances = Attendance.where(work_date: @dates)

    # 表示月の前後の月を取得
    @prev_month = @current_date.prev_month
    @next_month = @current_date.next_month

    # 月の総労働時間の取得
    @total_work_minutes = Attendance.total_work_minutes(@attendances)

    # 月の予想総労働時間の取得
    @expected_work_minutes = Attendance.expected_work_minutes(@dates, @setting)
  end

  ############################################ 手動出退勤処理 ################################################

  #################### 出勤処理 ########################
  def clock_in
    warning, message, result = @attendance.clock_in(@setting, @now)

    if warning.present?
      flash[:warning] = warning
    end

    if result
      flash[:notice] = message
    else
      flash[:alert] = message
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end

  #################### 退勤処理 ########################
  def clock_out
    warning, message, result = @attendance.clock_out(@setting, @now)

    if warning.present?
      flash[:warning] = warning
    end

    if result
      flash[:notice] = message
    else
      flash[:alert] = message
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end


  ############################################ 定時出退勤処理 ################################################

  #################### 定時出勤処理 ########################
  def setting_clock_in
    warning, message, result = @attendance.setting_clock_in(@setting, @now)

    if warning.present?
      flash[:warning] = warning
    end

    if result
      flash[:notice] = message
    else
      flash[:alert] = message
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end


  #################### 定時退勤処理 ########################

  def setting_clock_out
    warning, message, result = @attendance.setting_clock_out(@setting, @now)

    if warning.present?
      flash[:warning] = warning
    end


    if result
      flash[:notice] = message
    else
      flash[:alert] = message
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end

  #################### private処理 ########################

  private

  def set_attendance
    @attendance = Attendance.find_or_initialize_by(work_date: Date.today)
    @now = Time.current
  end

  def set_setting
    @setting = Setting.find_by(active: true)

    if @setting.nil?
      @setting = Setting.create!(
        break_time: 0,
        active: true
      )
    end
  end
end
