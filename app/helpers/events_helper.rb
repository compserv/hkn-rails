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
end
