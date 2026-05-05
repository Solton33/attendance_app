class Attendance < ApplicationRecord
  belongs_to :setting

  validates :work_date, presence: true
  validates :work_date, uniqueness: true
  validate :end_time_after_start_time
  validates :break_minutes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :work_minutes, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def end_time_after_start_time
    if start_time.blank? || end_time.blank?
      return
    end

    if end_time < start_time
      errors.add(:end_time, "は出勤時間より後にしてください")
    end
  end

  #################### 出勤処理 ########################
  def clock_in(setting, now)
    # 退勤打刻を既に打っている場合は出勤できないようにする
    if end_time.present?
      return [ nil, "退勤時刻は打刻済みです", false ]
    end

    # 設定を紐づけ（activeがtrueのものを設定）
    self.setting ||= setting
    current_setting = self.setting


    # 出勤日に出勤打刻があるかの確認
    if start_time.nil?
      self.start_time = now
      self.break_minutes = current_setting.break_time

      if save
        [ nil, "出勤時刻を打刻しました", true ]
      else
        [ nil, "出勤打刻に失敗しました", false ]
      end
    else
      [ nil, "出勤打刻は打刻済みです", false ]
    end
  end


  #################### 退勤処理 ########################
  def clock_out(setting, now)
    warning = nil

    # 退勤済みチェック
    if end_time.present?
      return [ warning, "退勤時刻は打刻済みです", false ]
    end

    if start_time.present? && now < start_time
      return [ warning, "退勤時刻が出勤時刻より前です", false ]
    end

    # setting紐付け
    self.setting ||= setting
    current_setting = self.setting

    # 出勤してない場合
    if start_time.nil?
      warning = "出勤打刻がされていません、後ほど修正してください"
      self.break_minutes = current_setting.break_time
    end

    # 通常退勤
    self.end_time = now

    # 休憩時間セット
    self.break_minutes ||= current_setting.break_time

    # 勤務時間計算
    if start_time && end_time && break_minutes
      self.work_minutes = calc_work_minutes
    end

    if save
      [ warning, "退勤打刻を打刻しました", true ]
    else
      [ warning, "退勤打刻に失敗しました", false ]
    end
  end


  #################### 定時出勤処理 ########################
  def setting_clock_in(setting, now)
    # 退勤済みチェック
    if end_time.present?
      return [ nil, "退勤時刻は打刻済みです", false ]
    end

    # setting紐付け
    self.setting ||= setting
    current_setting = self.setting

    # 定時出勤設定のチェック
    if current_setting.default_start_time.nil?
      return [ nil, "定時出勤が未設定です", false ]
    end

    # set_start_time作成
    set_start_time = now.change(
      hour: current_setting.default_start_time.hour,
      min: current_setting.default_start_time.min
    )

    # 遅刻、早出勤、出勤済みのチェック
    if now > set_start_time
      [ nil, "打刻時間が定時時間を過ぎています", false ]

    elsif set_start_time - 30.minutes > now
      [ nil, "打刻時間が早過ぎます、設定した時刻より30分未満の時点で打刻をしてください。", false ]

    elsif start_time.present?
      [ nil, "出勤打刻は打刻済みです", false ]

    else
      # 保存
      self.start_time = set_start_time
      self.break_minutes = current_setting.break_time

      if save
        [ nil, "出勤時刻を打刻しました", true ]
      else
        [ nil, "出勤打刻に失敗しました", false ]
      end
    end
  end

  #################### 定時退勤処理 ########################
  def setting_clock_out(setting, now)
    warning = nil

    if end_time.present?
      return [ warning, "退勤打刻は打刻済みです", false ]
    end

    # 当日の設定がされていない場合、ここで設定を紐づけ（activeがtrueのものを設定）
    self.setting ||= setting
    current_setting = self.setting

    # 定時退勤設定のチェック
    if current_setting.default_end_time.nil?
      return [ warning, "定時退勤が未設定です", false ]
    end

    # 打刻日時から日付を取得、時刻を設定時刻へ変更する
    set_end_time = now.change(
      hour: current_setting.default_end_time.hour,
      min: current_setting.default_end_time.min
      )

    # 定時前、出勤無しのチェック
    if now < set_end_time
      return [ warning, "打刻時間が定時時間より前です", false ]

    elsif start_time.nil?
      warning = "出勤打刻がされていません、後ほど修正してください"
      self.break_minutes = current_setting.break_time
    end

    self.end_time = set_end_time

    # 休憩時間セット
    self.break_minutes ||= current_setting.break_time

    # 勤務時間計算
    if start_time && end_time && break_minutes
      self.work_minutes = calc_work_minutes
    end

    if save
      [ warning, "退勤時刻を打刻しました", true ]
    else
      [ warning, "退勤打刻に失敗しました", false ]
    end
  end

  #################### 勤務時間計算処理 ########################
  # 出退勤後の勤務時間計算
  def calc_work_minutes
    # 出勤、退勤が揃っていない場合計算しない
    if !(start_time && end_time)
      return
    end

    # 勤務時間計算(分単位)
    ((end_time - start_time)/60).to_i - break_minutes.to_i
  end

  # 月の勤務時間合計
  def self.total_work_minutes(attendances)
    attendances
    .select { |a| a.start_time.present? && a.end_time.present? }
    .sum { |a| a.work_minutes.to_i }
  end

  # 月の予想総勤務時間合計
  def self.expected_work_minutes(dates, setting)
    # 定時出勤/退勤が設定されていない場合は計算しない
    if setting&.default_start_time.blank? || setting&.default_end_time.blank?
      return
    end

    # 土日以外の日数を算出
    work_days = dates.count { |date| date.wday != 0 && date.wday != 6 }

    # 定時の勤務時間を算出
    daily_minutes = ((setting.default_end_time - setting.default_start_time) / 60).to_i - setting.break_time.to_i

    if daily_minutes < 0
      return 0
    end

    # 日数と定時の勤務時間で合計算出
    work_days * daily_minutes
  end
end
