class AttendanceRequest < ApplicationRecord
  belongs_to :attendance

  validates :target_date, presence: true
  validates :reason, presence: true
  validate :at_least_one_change

  def at_least_one_change
    if requested_start_time.nil? && requested_end_time.nil? && requested_break_minutes.nil?
      errors.add(:base, "1箇所以上入力してください")
    end
  end
end
