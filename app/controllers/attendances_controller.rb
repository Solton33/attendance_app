class AttendancesController < ApplicationController
  before_action :set_attendance
  before_action :set_setting

#################### 出退勤時刻の表示 ########################
  def index
  end

############################################ 手動出退勤処理 ################################################

#################### 出勤処理 ########################
  def clock_in

    message, result = @attendance.clock_in(@setting,@now)

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
    # 出勤打刻がない場合、ここで設定を紐づけ（activeがtrueのものを設定）
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
      @attendance.end_time = @now
      @attendance.save!
      flash[:notice] = "退勤を打刻しました"
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end


############################################ 定時出退勤処理 ################################################

#################### 定時出勤処理 ########################
  def setting_clock_in

    if @setting.default_start_time.nil?
      flash[:alert] = "定時出勤が設定されていません"
      redirect_to root_path and return

    else
      # 打刻日時から日付を取得、時刻を設定時刻へ変更する
      set_start_time = @now.change(
          hour: @setting.default_start_time.hour,
          min: @setting.default_start_time.min
        )
    end

    # 退勤打刻を既に打っている場合は出勤できないようにする
    if @attendance.end_time.present?
      flash[:alert] = "退勤打刻が打刻済みです"
      redirect_to root_path and return
    end

    # 定時設定と現在の時刻の関係確認
    if @now > set_start_time
      flash[:alert] = "打刻した時間が設定した出勤時刻を過ぎています"
      redirect_to root_path and return

    elsif set_start_time - 30.minutes > @now
      flash[:alert] = "打刻時間が早過ぎます、設定した時刻より30分未満の時点で打刻をしてください。"
      redirect_to root_path and return

    else
      # 設定を紐づけ（activeがtrueのものを設定）
      @attendance.setting = @setting

      # 出勤日に出勤打刻があるかの確認
      if @attendance.start_time.nil?
        @attendance.start_time = set_start_time
        @attendance.break_minutes = @setting.break_time
        @attendance.save!

        flash[:notice] = "出勤を打刻しました"
      else
        flash[:alert] = "すでに出勤打刻済みです"
      end
    end

    # 打刻後にindex画面へ戻る
    redirect_to root_path
  end


#################### 定時退勤処理 ########################

  def setting_clock_out

    # 打刻時の時間を設定
    now = @now

    # 当日の設定がされていない場合、ここで設定を紐づけ（activeがtrueのものを設定）
    @attendance.setting ||= @setting

    # 定時退勤の設定があるか確認
    if @setting.default_end_time.nil?
      flash[:alert] = "定時退勤が設定されていません"
      redirect_to root_path and return
    end

    # 打刻日時から日付を取得、時刻を設定時刻へ変更する
    set_end_time = now.change(
      hour: @setting.default_end_time.hour,
      min: @setting.default_end_time.min
      )

    # 取得した日時が、定時退勤より前だった場合はエラー
    if now < set_end_time
      flash[:alert] = "打刻した時間が設定した退勤時刻より前です。"
      redirect_to root_path and return
    end

    # 退勤打刻が既にあるかの判定
    if @attendance.end_time.present?
      flash[:alert] = "退勤打刻済みです。"
      redirect_to root_path and return
    end

    # 出勤打刻があるかの判定
    if @attendance.start_time.nil?
      flash[:alert] = "出勤打刻がされていません、後ほど修正してください"
      @attendance.break_minutes = @setting.break_time
    end

    @attendance.end_time = set_end_time
    @attendance.save!
    flash[:notice] = "退勤を打刻しました"

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
