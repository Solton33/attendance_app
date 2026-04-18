class Attendance < ApplicationRecord
  belongs_to :setting

  #################### 出勤処理 ########################
  def clock_in(setting, now)
    # 退勤打刻を既に打っている場合は出勤できないようにする
    if end_time.present?
      return [ "退勤時刻は打刻済みです", false ]
    end

    # 設定を紐づけ（activeがtrueのものを設定）
    self.setting ||= setting

    # 出勤日に出勤打刻があるかの確認
    if start_time.nil?
      self.start_time = now
      self.break_minutes = setting.break_time
      save!

      [ "出勤時刻を打刻しました", true ]
    else
      [ "出勤打刻は打刻済みです", false ]
    end
  end


  #################### 退勤処理 ########################
  def clock_out(setting, now)
    warning = nil

    # 退勤済みチェック
    if end_time.present?
      return [ warning, "退勤時刻は打刻済みです", false ]
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

    [ warning, "退勤時刻を打刻しました", true ]
  end


  #################### 定時出勤処理 ########################
  def setting_clock_in(setting, now)
    # 退勤済みチェック
    if end_time.present?
      return [ "退勤時刻は打刻済みです", false ]
    end

    # 定時出勤設定のチェック
    if setting.default_start_time.nil?
      return [ "定時出勤が未設定です", false ]
    end

    # set_start_time作成
    set_start_time = now.change(
      hour: setting.default_start_time.hour,
      min: setting.default_start_time.min
    )

    # 遅刻、早出勤、出勤済みのチェック
    if now > set_start_time
      [ "打刻時間が定時時間を過ぎています", false ]

    elsif set_start_time - 30.minutes > now
      [ "打刻時間が早過ぎます、設定した時刻より30分未満の時点で打刻をしてください。", false ]

    elsif start_time.present?
      [ "出勤打刻は打刻済みです", false ]

    else
      # setting紐付け
      self.setting ||= setting

      # 保存
      self.start_time = set_start_time
      self.break_minutes = setting.break_time
      save!

      [ "出勤時刻を打刻しました", true ]
    end
  end

  #################### 定時退勤処理 ########################
  def setting_clock_out(setting, now)
    warning = nil

    # 当日の設定がされていない場合、ここで設定を紐づけ（activeがtrueのものを設定）
    self.setting ||= setting

    # 定時退勤設定のチェック
    if setting.default_end_time.nil?
      return [ warning, "定時退勤が未設定です", false ]
    end

    # 打刻日時から日付を取得、時刻を設定時刻へ変更する
    set_end_time = now.change(
      hour: setting.default_end_time.hour,
      min: setting.default_end_time.min
      )

    # 定時前、退勤済み、出勤無しのチェック
    if now < set_end_time
      return [ warning, "打刻時間が定時時間より前です", false ]

    elsif end_time.present?
      return [ warning, "退勤打刻は打刻済みです", false ]

    elsif start_time.nil?
      warning = "出勤打刻がされていません、後ほど修正してください"
      self.break_minutes = setting.break_time
    end

    self.end_time = set_end_time
    save!

    [ warning, "退勤時刻を打刻しました", true ]
  end
end
