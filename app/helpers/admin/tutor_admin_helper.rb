module Admin::TutorAdminHelper
  def availability_form_name(wday, hour, field=nil)
    s = "availabilities[#{wday}][#{hour}]"
    unless field.blank?
      s += "[#{field}]"
    end
    return s
  end

  def formatslot(day, hour)
    return day[0..2] + hour
  end

  def format_hour(hour)
    if hour < 12
      return hour.to_s + "AM"
    elsif hour == 12
      return hour.to_s + "PM"
    else
      return (hour-12).to_s + "PM"
    end
  end
  
  def format_hour_slot(hour)
    return format_hour(hour) + "-" + format_hour(hour+1)
  end
end
