class HomeController < ApplicationController
  helper EventsHelper

  def index
    @events = Event.upcoming_events(0, @current_user)
    @show_searcharea = true
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @hours = prop.tutoring_start .. prop.tutoring_end
    time = Time.now.in_time_zone('Pacific Time (US & Canada)')

    time = time.tomorrow if time.hour > prop.tutoring_end
    time = time.next_week unless (1..5).include? time.wday
    @day = time.wday
    @tutor_title = "#{time.strftime("%A")}'s Tutoring Schedule"

    if @tutoring_enabled
      @course_mapping = {}
      @slots = Slot.includes(:tutors).where(wday: time.wday)
    else
      @tutoring_message = prop.tutoring_message
    end
    
    # Only respond with HTML to not error when other formats are requested
    respond_to :html
  end

  def factorial
    x = params[:x].to_i
    y = case
    when x < 0
      'u dumb'
    when x > 9000
      redirect_to "http://www.youtube.com/watch?v=SiMHTK15Pik"
      return
    else
      y = x.downto(1).inject(:*)
    end
    redirect_to :root, notice: y
  end
end
