module ApplicationHelper
  def format_minutes(minutes)
    if !(minutes)
      return ""
    end

    hours = minutes / 60
    mins = minutes % 60

    "#{hours}:#{mins.to_s.rjust(2, '0')}"
  end
end
