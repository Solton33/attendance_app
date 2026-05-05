module ApplicationHelper
  def format_minutes(minutes)
    if !(minutes)
      return ""
    end

    hours = minutes / 60
    mins = minutes % 60

    "#{hours}:#{mins.to_s.rjust(2, '0')}"
  end

  def row_class(date)
    classes = []
    classes << "today-row" if date == Date.current
    classes << "sunday" if date.wday == 0
    classes << "saturday" if date.wday == 6
    classes.join(" ")
  end

  def work_minutes_display(work_list)
    if !(work_list)
      return ""
    elsif work_list.start_time.blank? || work_list.end_time.blank?
      return "-"
    end
    format_minutes(work_list.work_minutes)
  end
end
