class RsvpsController < ApplicationController
  before_filter :get_event

  # GET /rsvps
  # GET /rsvps.xml
  def index
    @rsvps = @event.rsvps

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rsvps }
    end
  end

  # GET /rsvps/1
  # GET /rsvps/1.xml
  def show
    @rsvp = Rsvp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rsvp }
    end
  end

  # GET /rsvps/new
  # GET /rsvps/new.xml
  def new
    @rsvp = Rsvp.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rsvp }
    end
  end

  # GET /rsvps/1/edit
  def edit
    @rsvp = Rsvp.find(params[:id])
    validate_owner!(@rsvp)
  end

  # POST /rsvps
  # POST /rsvps.xml
  def create
    @rsvp = Rsvp.new(params[:rsvp])
    assign_blocks

    respond_to do |format|
      if @rsvp.save
        format.html { redirect_to(@event, :notice => 'Rsvp was successfully created.') }
        format.xml  { render :xml => @rsvp, :status => :created, :location => @rsvp }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rsvp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rsvps/1
  # PUT /rsvps/1.xml
  def update
    @rsvp = Rsvp.find(params[:id])
    validate_owner!(@rsvp)
    assign_blocks

    respond_to do |format|
      if @rsvp.update_attributes(params[:rsvp])
        format.html { redirect_to(event_rsvp_path(@event, @rsvp), :notice => 'Rsvp was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rsvp.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rsvps/1
  # DELETE /rsvps/1.xml
  def destroy
    @rsvp = Rsvp.find(params[:id])
    validate_owner!(@rsvp)
    @rsvp.destroy

    respond_to do |format|
      format.html { redirect_to(event_rsvps_url(@event)) }
      format.xml  { head :ok }
    end
  end

  def my_rsvps
    @rsvps = @current_user.rsvps
  end


  def validate_owner!(rsvp)
    unless @current_user == rsvp || @auth['superusers']
      raise 'You do not have permission to modify this RSVP'
    end
  end

  def get_event
    @event = Event.find params[:event_id] unless params[:event_id].blank?
  end

  def assign_blocks
    if @event.blocks.size > 1
      @rsvp.block_ids = params[:block] && params[:block].keys || []
    else
      @rsvp.blocks = @event.blocks
    end
  end
end
