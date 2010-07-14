module Admin::TutorAdminHelper
  def formatslot(day, hour)
    return day[0..2] + hour
  end
  
  def default_radio(prefs, day, hour, pref)
    return 'checked="checked"' if prefs[formatslot(day, hour)] == pref
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

  def tutors_for_slot(day, hour, room)
    wday = Slot.day_to_wday[day]
    slot = Slot.find_by_time_and_room(lot.get_time(wday, hour), room)
    return slot.tutors
  end
  def available_tutors_for_slot(day, hour)
    wday = Slot.day_to_wday[day]
    slot = Slot.find_by_time(Slot.get_time(wday, hour))
    return slot.availabilities.map { |x| x.tutor}
  end
end
