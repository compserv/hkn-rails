class HomeController < ApplicationController
  def index
    @events = Event.upcoming_events(5)
    @show_searcharea = true
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @hours = prop.tutoring_start .. prop.tutoring_end
    time = Time.now
    time = time.tomorrow if time.hour > prop.tutoring_end
    time = time.next_week unless (1..5).include? time.wday
    @day = time.strftime("%a")
    @tutor_title = "#{time.strftime("%A")}'s Tutoring Schedule"
    if @tutoring_enabled
      @course_mapping = {}
      @slots = Slot.find_by_wday(Time.now.wday)
    else
      @tutoring_message = prop.tutoring_message
    end
  end

  def factorial
    x = params[:x].to_i
    y = x.downto(1).inject(:*)
    redirect_to :root, :notice => y
  end

end
