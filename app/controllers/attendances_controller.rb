class AttendancesController < ApplicationController
  before_action :set_setting

#################### 出退勤時刻の表示 ########################  

  def index
    @attendance = Attendance.find_by(work_date:Date.today)
  end

#################### 出勤処理 ########################
  
  def clock_in
    # 今日の勤怠を取得 or 新規作成
    @attendance = Attendance.find_or_initialize_by(work_date: Date.today)

    # 退勤打刻を既に打っている場合は出勤できないようにする
    if @attendance.end_time.present?
      flash[:alert] = "退勤打刻が設定済みです"
      redirect_to root_path and return
    end

    # 設定を紐づけ（activeがtrueのものを設定）
    @attendance.setting = @setting

    # 出勤日に出勤打刻があるかの確認
    if @attendance.start_time.nil?
      @attendance.start_time = Time.current
      @attendance.break_minutes = @setting.break_time
      @attendance.save!

      flash[:notice] = "出勤を打刻しました"
    else
      flash[:alert] = "すでに出勤打刻済みです"
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end

#################### 退勤処理 ########################

  def clock_out
    # 今日の勤怠を取得 or 新規作成
    @attendance = Attendance.find_or_initialize_by(work_date: Date.today)
          # 出勤打刻がないのでここで設定を紐づけ（activeがtrueのものを設定）
      if @attendance.setting.nil? 
        @attendance.setting = @setting
      end

    # 今日の日付がない = 出勤がされていないので警告後に退勤のみ打刻 
    if @attendance.start_time.nil? && @attendance.end_time.nil?
      flash[:alert] = "出勤打刻がされていません、後ほど修正してください"

      @attendance.end_time = Time.current
      @attendance.break_minutes ||= @setting.break_time
      @attendance.save!
      flash[:notice] = "退勤を打刻しました"

    elsif @attendance.end_time.present?
      flash[:alert] = "すでに退勤打刻済みです"

      redirect_to root_path and return

    else
      @attendance.end_time = Time.current
      @attendance.save!
      flash[:notice] = "退勤を打刻しました" 
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end
  

#################### private処理 ########################

  private

  def set_setting
    @setting = Setting.find_by(active: true)

    if @setting.nil?
      flash[:alert] = "有効な設定がありません"
      redirect_to root_path and return
    end
  end

end
