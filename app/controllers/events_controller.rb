class EventsController < ApplicationController
  before_filter :authorize_act, :except => [:index, :calendar, :show]
  # GET /events
  # GET /events.xml
  def index
    category = params[:category] || 'all'
    # We should paginate this
    if category == 'past'
      @events = Event.includes(:event_type).order(:start_time).where(['start_time < ?', Time.now])
      @heading = "Past Events"
    elsif category == 'future'
      @events = Event.includes(:event_type).order(:start_time).where(['start_time > ?', Time.now])
      @heading = "Upcoming Events"
    else
      @events = Event.includes(:event_type).order(:start_time)
      @heading = "All Events"
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def calendar
    month = (params[:month] || Time.now.month).to_i
    year = (params[:year] || Time.now.year).to_i
    @start_date = Date.civil(year, month).beginning_of_month
    @end_date = Date.civil(year, month).end_of_month
    @events = Event.find(:all, :conditions => { :start_time => @start_date..@end_date }, :order => :start_time)
    # Really convoluted way of getting the first Sunday of the calendar, 
    # which usually lies in the previous month
    @calendar_start_date = (@start_date.wday == 0) ? @start_date : @start_date.next_week.ago(8.days)
    # Ditto for last Saturday
    @calendar_end_date = (@end_date == 0) ? @end_date.since(6.days) : @end_date.next_week.ago(2.days)

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace 'calendar-wrapper', :partial => 'calendar'
        end
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])
    @blocks = @event.blocks
    @current_user_rsvp = @event.rsvps.find_by_person_id(@current_user.id) if @current_user
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = Event.new(params[:event])
    duration = @event.end_time - @event.start_time
    blocks = Integer(params[:num_blocks])
    block_length = duration/blocks
    
    @debug << "We want " + blocks.to_s + " blocks that are " + block_length.to_s + " seconds long"
    #For now, let's just stick to one block per event. The UI for multiple blocks is
    #going to need javascript in order to not suck.
    
    @block = Block.new
    @block.event = @event
    @block.start_time = @event.start_time
    @block.end_time = @event.end_time
    respond_to do |format|
      if @event.save
        @block.save
        format.html { redirect_to(@event, :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(@event, :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end
end
