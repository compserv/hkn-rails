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
    start, stop = [hour, hour + 1]
    if applyTempFix
      if start == 11 or start == 12
        start = start + 2
        stop = stop + 2
      elsif start == (1 + 12)
        # Large slot between 3 PM to 7 PM - for No Tutoring
        start = start + 2
        stop = stop + 5
      else (2 + 12) <= start and start <= (4 + 12)
        start = start + 5
        stop = stop + 5
      end
    end
    
    return format_hour(start) + "-" + format_hour(stop)
  end
end
