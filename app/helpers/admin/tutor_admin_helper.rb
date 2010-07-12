module Admin::TutorAdminHelper
  def formatslot(day, hour)
    day[0..2] + hour
  end
  
  def default_radio(user, day, hour, pref)
    slots_available = user.tutor.availability.slots.map { |x| x.to_s }
    available_now = slots_available.include? formatslot(day, hour)
    'checked="checked"' if available_now ^ (pref == "unavailable")
  end
end
