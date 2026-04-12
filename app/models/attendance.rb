class Attendance < ApplicationRecord
  belongs_to :setting

  #################### 出勤処理 ########################
  def clock_in(setting,now)
    # 退勤打刻を既に打っている場合は出勤できないようにする
    if end_time.present?
      return ["退勤時刻は打刻済みです", false]
    end

    # 設定を紐づけ（activeがtrueのものを設定）
    self.setting ||= setting

    # 出勤日に出勤打刻があるかの確認
    if start_time.nil?
      self.start_time = now
      self.break_minutes = setting.break_time
      save!

      return ["出勤時刻を打刻しました", true]
    else
      return ["すでに出勤打刻済みです", false]
    end
  end


#################### 退勤処理 ########################
  def clock_out(setting,now)
    warning = nil

    # 退勤済みチェック
    if end_time.present?
      return [warning, "退勤時刻は打刻済みです", false]
    end

    # setting紐付け
    self.setting ||= setting
    
    # 出勤してない場合
    if start_time.nil?
      warning = "出勤打刻がされていません、後ほど修正してください"
      self.break_minutes ||= setting.break_time
    end
    
    # 通常退勤
    self.end_time = now
    save!

    [warning, "退勤時刻を打刻しました", true]
  end













end
