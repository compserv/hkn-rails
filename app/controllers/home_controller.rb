class HomeController < ApplicationController
  def index
    @show_searcharea = true
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @hours = prop.tutoring_start .. prop.tutoring_end
    if (1..5) === Time.now.wday
      @day = Time.now.strftime("%a")
      @tutor_title = "Today's tutoring schedule"
    else
      @day = "Mon"
      @tutor_title = "Monday's tutoring schedule"
    end
    @tutoring_message = prop.tutoring_message
  end

end
