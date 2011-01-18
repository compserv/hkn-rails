class HomeController < ApplicationController
  def index
    @events = Event.upcoming_events(3)
    @show_searcharea = true
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    if @tutoring_enabled
      @hours = prop.tutoring_start .. prop.tutoring_end
      if (1..5) === Time.now.wday
        @day = Time.now.strftime("%a")
        @tutor_title = "Today's tutoring schedule"
      else
        @day = "Mon"
        @tutor_title = "Monday's tutoring schedule"
      end
      @course_mapping = {}
      @slots = Slot.find_by_wday(Time.now.wday)
    else
      @tutoring_message = prop.tutoring_message
    end
  end

end
