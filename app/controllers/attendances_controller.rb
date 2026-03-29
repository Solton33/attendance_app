class AttendancesController < ApplicationController
  before_action :set_setting

  def index # 当日の内容を表示
    @attendance = Attendance.find_by(work_date:Date.today)
  end


  def clock_in
    # 今日の勤怠を取得 or 新規作成
    @attendance = Attendance.find_or_initialize_by(work_date: Date.today)

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


  def clock_out # 退勤処理
    # 今日の勤怠を取得 or 新規作成
    @attendance = Attendance.find_or_initialize_by(work_date: Date.today)
    
    # 設定をがなければ紐づけ（activeがtrueのものを設定）
    if @attendance.setting.nil?
      @attendance.setting = @setting
      @attendance.break_minutes = @setting.break_time
    end

    # 出勤打刻がない場合は、その旨のアラートを表示
    if @attendance.start_time.nil?
      flash[:alert] = "出勤打刻がされていません"

      @attendance.end_time = Time.current
      @attendance.save!
      flash[:notice] = "退勤を打刻しました" 
    
    else
      # 退勤日に退勤打刻があるかの確認
      if @attendance.end_time.present?
        flash[:alert] = "すでに退勤打刻済みです"
        redirect_to root_path and return

      else
        # 退勤打刻をして保存
        @attendance.end_time = Time.current
        @attendance.save!
        flash[:notice] = "退勤を打刻しました" 
      end
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end


  private

  def set_setting
    @setting = Setting.find_by(active: true)

    if @setting.nil?
      flash[:alert] = "有効な設定がありません"
      redirect_to root_path and return
    end
  end

end
