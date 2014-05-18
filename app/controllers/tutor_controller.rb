class TutorController < ApplicationController

  #caches_action :schedule, :layout => false
    
  def schedule
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @tutoring_message = prop.tutoring_message
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @wdays = 1..5
    @hours = prop.tutoring_start .. prop.tutoring_end
    @room_numbers = ["290 Cory", "345 Soda"]
    @rows = @hours
  end

  def calendar
    month = (params[:month] || Time.now.month).to_i
    year = (params[:year] || Time.now.year).to_i
    # TODO: Fix this, I think we have timezone issues
    @start_date = Time.local(year, month).beginning_of_month
    @end_date = Time.local(year, month).end_of_month
    @events = Event.with_permission(@current_user)
        .where(start_time: @start_date..@end_date)
        .order(:start_time)

    @events = @events.select { |e| 
        EventType.where("name IN (?)", ["Exam", "Review Session"])
                 .include?(e.event_type)
    }
    # Really convoluted way of getting the first Sunday of the calendar, 
    # which usually lies in the previous month
    @calendar_start_date = (@start_date.wday == 0) ? @start_date : @start_date.next_week.ago(8.days)
    # Ditto for last Saturday
    @calendar_end_date = (@end_date.wday == 0) ? @end_date.since(6.days) : @end_date.next_week.ago(2.days)

    respond_to do |format|
      format.html
      format.js {
        render :partial => 'calendar'
      }
    end
  end

end
