class Setting < ApplicationRecord
  has_many :attendances

  validate :end_after_start
  validates :break_time, numericality: { greater_than_or_equal_to: 0 }

  def end_after_start
    if default_start_time.blank? || default_end_time.blank?
      retrun
    end

    if default_end_time <= default_start_time
      errors.add(:default_end_time, "は出勤時間より後にしてください")
    end
  end
end
