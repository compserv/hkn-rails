class EventsController < ApplicationController
  before_filter :authorize_comms, :except => [:index, :calendar, :show, :hkn, :ical]
  
  #[:index, :calendar, :show].each {|a| caches_action a, :layout => false}

  # GET /events
  # GET /events.xml
  def index
    per_page = 20
    order = params[:sort] || "start_time"
    params[:sort_direction] ||= (category == 'past') ? 'down' : 'up'
    
    sort_direction = case params[:sort_direction]
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end
    @search_opts = {'sort' => order, 'sort_direction' => sort_direction }.merge params
    # Maintains start_time as secondary sort column
    opts = { :page => params[:page], :per_page => per_page, :order => "#{order} #{sort_direction}, start_time #{sort_direction}" }

    category = params[:category] || 'all'
    event_finder = Event.with_permission(@current_user)
    # We should paginate this
    if category == 'past'
      @events = event_finder.past
      @heading = "Past Events"
    elsif category == 'future'
      @events = event_finder.upcoming
      @heading = "Upcoming Events"
    else
      #@events = Event.includes(:event_type).order(:start_time)
      @events = event_finder
      @heading = "All Events"
    end

    @events = @events.paginate opts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
      format.js { render :partial => 'list' }
    end
  end

  #Controller action for main confirmation page that links to each event confirmation page
  def vp_confirm
    types = ["Mandatory for Candidates", "Big Fun", "Fun", "Community Service"]

    #Filters for candidate events (enumerated in "types" variable)
    candEventTypes = EventType.find(:all, :conditions => ["name IN (?)", types])
    candEventTypeIDs = candEventTypes.map{|event_type| event_type.id}
    #@events = Event.past.find(:all, :conditions => ["event_type_id IN (?)", candEventTypeIDs], :order => :start_time)    
    # Sorry, this is kind of a bad query
    @events = Event.past.find(:all, :joins => { :rsvps => {:person => :groups} }, :conditions => "rsvps.confirmed IS NULL AND groups.id = #{Group.find_by_name('candidates').id}").uniq
    @events.sort!{|x, y| x.start_time <=> y.end_time }.reverse!
  end

  #Rsvp confirmation for an individual event
  def rsvps_confirm
    @event = Event.find(params[:id])
    @rsvps = @event.rsvps.sort_by { |rsvp| rsvp.person.last_name }
  end
        
  def calendar
    month = (params[:month] || Time.now.month).to_i
    year = (params[:year] || Time.now.year).to_i
    # TODO: Fix this, I think we have timezone issues
    @start_date = Time.local(year, month).beginning_of_month
    @end_date = Time.local(year, month).end_of_month
    @events = Event.with_permission(@current_user).find(:all, :conditions => { :start_time => @start_date..@end_date }, :order => :start_time)
    # Really convoluted way of getting the first Sunday of the calendar, 
    # which usually lies in the previous month
    @calendar_start_date = (@start_date.wday == 0) ? @start_date : @start_date.next_week.ago(8.days)
    # Ditto for last Saturday
    @calendar_end_date = (@end_date == 0) ? @end_date.since(6.days) : @end_date.next_week.ago(2.days)

    respond_to do |format|
      format.html
      format.js {
        render :partial => 'calendar'
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    begin
      # Only show event if user has permission to
      @event = Event.with_permission(@current_user).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to :root, :notice => "Event not found"
      return
    end
    @blocks = @event.blocks
    @current_user_rsvp = @event.rsvps.find_by_person_id(@current_user.id) if @current_user
    if @event.need_transportation
      @total_transportation = @event.rsvps.map{|rsvp| rsvp.transportation}.sum
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    @blocks = @event.blocks

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
    @blocks = @event.blocks
  end

  # POST /events
  # POST /events.xml
  def create
    
    @event = Event.new(params[:event])
    duration = @event.end_time - @event.start_time
    @blocks = []

    valid = true
    case params[:rsvp_type]
    when 'No RSVPs'
    when 'Whole Event RSVPs'
      # Implies one block with the same start and end time as the event
      block = Block.new
      block.event = @event
      block.start_time = @event.start_time
      block.end_time = @event.end_time
      block.rsvp_cap = params[:rsvp_cap]
      @blocks << block
    when 'Block RSVPs'
      num_blocks = params[:num_blocks].to_i # Invalid strings are mapped to 0
      if params[:uniform_blocks]
        block_length = duration/num_blocks
        num_blocks.times do |i|
          block = Block.new
          block.event = @event
          start_time = @event.start_time + (block_length * i)
          block.start_time = start_time 
          block.end_time = start_time + block_length
          block.rsvp_cap = params[:rsvp_cap]
          @blocks << block
        end
      else
        # We assume that if block times are manually set, then they will appear
        # in params hashed as block0, block1, etc...
        params.keys().reject{|x| !(x =~ /block\d+/)}.each do |block_name|
          #block = Block.new(params["block#{i}"])
          block_hash = params[block_name]
          if block_hash.has_key?('id')
            block = Block.find(block_hash['id'])
            block.update_attributes(block_hash)
          else
            block = Block.new(params[block_name])
          end
          block.event = @event
          @blocks << block
        end
      end
    else
      #raise "Invalid RSVP type"
      valid = false
      @event.errors[:base] << "Invalid RSVP type"
    end

    if valid
      begin
        # Don't save event if any block is invalid
        ActiveRecord::Base.transaction do
          @event.save!
          @blocks.each do |block| 
            block.save!
          end
        end
      rescue
        valid = false
      end
    end

    respond_to do |format|
      if valid
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
    @blocks = @event.blocks
    original_start = @event.start_time
    original_end = @event.end_time

    @event.update_attributes!(params[:event])

    # Don't save event if any block is invalid
    valid = true
    ActiveRecord::Base.transaction do
      begin

        case params[:rsvp_type]
        when 'No RSVPs'
          # Delete existing blocks and any RSVPs
          @event.blocks.delete_all
          @event.rsvps.delete_all
        when 'Whole Event RSVPs'
          # Implies one block with the same start and end time as the event
          case @event.blocks.size
          when 0
            block = Block.new
          when 1
            block = @event.blocks[0]
          else
            @event.blocks.delete_all
            block = Block.new
          end
          block.event = @event
          block.start_time = @event.start_time
          block.end_time = @event.end_time
          block.rsvp_cap = params[:rsvp_cap]
          @blocks = [block]
        when 'Block RSVPs'
          num_blocks = params[:num_blocks].to_i # Invalid strings are mapped to 0
          # We will destroy all existing blocks if uniform_blocks is selected.
          # Even if event was originally created with uniform_blocks selected,
          # the edit page should display it in manual block mode, which will 
          # preserve any blocks that the user does not explicitly delete.
          if params[:uniform_blocks]
            @event.blocks.delete_all
            @blocks = []
            duration = @event.end_time - @event.start_time
            block_length = duration/num_blocks
            num_blocks.times do |i|
              block = Block.new
              block.event = @event
              start_time = @event.start_time + (block_length * i)
              block.start_time = start_time 
              block.end_time = start_time + block_length
              block.rsvp_cap = params[:rsvp_cap]
              @blocks << block
            end
          else
            # We assume that if block times are manually set, then they will appear
            # in params hashed as block0, block1, etc...
            old_blocks = @event.blocks
            new_blocks = []
            params.keys().reject{|x| !(x =~ /block\d+/)}.each do |block_name|
              block_hash = params[block_name]
              if block_hash.has_key?('id')
                block = Block.find(block_hash['id'])
                block.update_attributes(block_hash)
              else
                block = Block.new(params[block_name])
              end
              block.event = @event
              new_blocks << block
            end

            old_blocks.each do |block|
              if !new_blocks.include?(block)
                block.delete
              end
            end

            @blocks = new_blocks
          end
        else
          valid = false
          @event.errors[:base] << "Invalid RSVP type"
        end

        @blocks.each do |block| 
          block.save!
        end
      rescue ActiveRecord::ActiveRecordError
        valid = false
      end
    end # end transaction

    respond_to do |format|
      if valid
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

  def hkn
    # WE NEED A SEMESTER CLASS
    semester = params[:semester] || Property.semester
    semester = semester.to_s
    semester_year = semester[0..3]

    # 1 = Spring, 2 = Summer, 3 = Fall
    case semester[4..4]
    when "1"
      semester_start_month = 1
      semester_end_month = 5
    when "2"
      semester_start_month = 6
      semester_end_month = 7
    when "3"
      semester_start_month = 8
      semester_end_month = 12
    else
      raise "Error!"
    end

    start_month = ( params[:start_month] || semester_start_month ).to_i
    start_year = ( params[:start_year] || semester_year ).to_i

    end_month = ( params[:end_month] || semester_end_month ).to_i
    end_year = ( params[:end_year] || semester_year ).to_i

    @start_date = Time.local(start_year, start_month).beginning_of_month
    @end_date = Time.local(end_year, end_month).end_of_month

    @now = Time.now

    @events = Event.with_permission(@current_user).find(:all, :conditions => { :start_time => @start_date..@end_date }, :order => :start_time)
    # Really convoluted way of getting the first Sunday of the calendar, 
    # which usually lies in the previous month
    
    respond_to do |format|
      format.html { render :hkn, :layout => false }
      format.ics {
        render :text => generate_ical_text(@events)
      }
    end
  end
  
  def ical
    return self.hkn
  end
  
  private
  
  def generate_ical_text(events)
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
      # the following are x-properties and so are set manually
      cal.add_x_property "X-WR-CALNAME","HKN Events"
      cal.add_x_property "X-WR-CALDESC","HKN Events"
    end
    headers['Content-Type'] = "text/calendar; charset=UTF-8"
    cal.to_s
  end
end
