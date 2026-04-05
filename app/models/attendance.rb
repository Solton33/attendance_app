class Attendance < ApplicationRecord
  belongs_to :setting

  #################### 出勤処理 ########################
  def clock_in(setting,now)
    # 退勤打刻を既に打っている場合は出勤できないようにする
    if end_time.present?
      return ["退勤打刻が打刻済みです", false]
    end

    # 設定を紐づけ（activeがtrueのものを設定）
    self.setting ||= setting

    # 出勤日に出勤打刻があるかの確認
    if start_time.nil?
      self.start_time = now
      self.break_minutes = setting.break_time
      save!

      return ["出勤を打刻しました", true]
    else
      return ["すでに出勤打刻済みです", false]
    end
  end

end
