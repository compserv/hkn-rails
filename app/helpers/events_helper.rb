module EventsHelper
  # These two functions were directly pulled from the Django site
  def icaldate(time)
    time.strftime("%Y%m%dT%H%M%S")
  end

  # width is the fieldname's width in characters
  # Pay attention to how Ruby handles escape characters here
  def icalify(str, width=0) 
    str = str.sub("\r\n", '\n').sub("\n", '\n')
    ((74-width)..(str.length)).step(74) do |x|
      str.insert(x, "\n ")
    end
    return str
  end
  
  def generate_ical(events)
    cal = RiCal.Calendar do |cal|
      events.each do |event|
        cal.event do |iCalEvent|
          iCalEvent.description = event.description
          iCalEvent.summary = event.name
          iCalEvent.dtstart = event.start_time
          iCalEvent.dtend   = event.end_time
          iCalEvent.location = event.location
        end
      end
    end
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    cal.to_s
  end
end
