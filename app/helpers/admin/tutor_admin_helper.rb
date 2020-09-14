module Admin::TutorAdminHelper
  def availability_form_name(wday, hour, field=nil)
    s = "availabilities[#{wday}][#{hour}]"
    unless field.blank?
      s += "[#{field}]"
    end
    return s
  end

  def slot_id(room, wday, hour)
    "#{room}-#{wday}-#{hour}"
  end

  def format_hour(hour)
    ampm = (12..23).include?(hour) ? 'PM' : 'AM'
    hour -= 12 if hour > 12
    return hour.to_s + ampm
  end

  def format_hour_slot(hour)
    applyTempFix = true
    hour = hour + ((hour >= 15 && applyTempFix) ? 5 : 0)
    return format_hour(hour) + "-" + format_hour(hour+1)
  end
end
