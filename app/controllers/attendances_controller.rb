class AttendancesController < ApplicationController
  before_action :set_attendance
  before_action :set_setting

  #################### 出退勤時刻の表示 ########################
  def index
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
      flash[:alert] = "有効な設定がありません"
      redirect_to root_path and return
    end
  end
end
