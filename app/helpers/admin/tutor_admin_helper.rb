module Admin::TutorAdminHelper
  def formatslot(day, hour)
    return day[0..2] + hour
  end
  
  def default_radio(user, day, hour, pref)
    slots_available = user.tutor.availability.slots.map { |x| x.to_s }
    available_now = slots_available.include? formatslot(day, hour)
    return 'checked="checked"' if available_now ^ (pref == "unavailable")
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
