class RsvpsController < ApplicationController
  before_filter :get_event
  before_filter :rsvp_permission, except: [:my_rsvps, :confirm, :unconfirm, :reject]
  before_filter(only: [:confirm, :unconfirm, :reject]) { |c| c.authorize(['pres', 'vp']) }
  before_filter :authorize

  # GET /rsvps
  # GET /rsvps.xml
  def index
    # Most recently created RSVPs will show on top of the list
    rsvps = @event.rsvps.order(:created_at)
    cap = @event.cap
    if cap.nil? or cap < 1
      # No cap
      admitted = rsvps
      waitlist = []
    else
      admitted = rsvps[0...cap]
      waitlist = rsvps[cap..-1]
    end

    @rsvp_lists = [["Admitted", admitted], ["Waitlist", waitlist]]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: rsvps }
    end
  end

  # GET /rsvps/1
  # GET /rsvps/1.xml
  def show
    @rsvp = Rsvp.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @rsvp }
    end
  end

  # GET /rsvps/new
  # GET /rsvps/new.xml
  def new
    # Allow all RSVPS, but waitlist
    @rsvp = Rsvp.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @rsvp }
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
    @rsvp           = Rsvp.new(rsvp_params)
    @rsvp.event     = @event
    @rsvp.person    = @current_user
    @rsvp.confirmed = Rsvp::Unconfirmed

    assign_blocks

    respond_to do |format|
      if @rsvp.save
        if @rsvp.waitlist_spot > 0
          format.html { redirect_to(@event, notice: "RSVP successful. You are on the waitlist, position #{@rsvp.waitlist_spot}") }
          format.xml  { render xml: @rsvp, status: :created, location: @rsvp }
        else
          format.html { redirect_to(@event, notice: 'Thanks for RSVPing! See you there!') }
          format.xml  { render xml: @rsvp, status: :created, location: @rsvp }
        end
      else
        format.html { render action: "new" }
        format.xml  { render xml: @rsvp.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rsvps/1
  # PUT /rsvps/1.xml
  def update
    @rsvp = Rsvp.find(params[:id])
    validate_owner!(@rsvp)
    assign_blocks

    @rsvp.update_attributes(rsvp_params)

    respond_to do |format|
      if @rsvp.save
        format.html { redirect_to(@event, notice: 'Rsvp was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @rsvp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rsvps/1
  # DELETE /rsvps/1.xml
  def destroy
    @rsvp = Rsvp.find(params[:id])
    validate_owner!(@rsvp)
    @event = @rsvp.event
    @rsvp.destroy

    respond_to do |format|
      format.html { redirect_to(@event) }
      format.xml  { head :ok }
    end
  end

  def confirm
    @rsvp = Rsvp.find(params[:id])
    @rsvp.confirmed = Rsvp::Confirmed

    group = params[:group] || "candidates"

    respond_to do |format|
      if @rsvp.update_attribute :confirmed, Rsvp::Confirmed   # TODO (jonko) this bypasses validation
        format.html { redirect_to(confirm_rsvps_path(@rsvp.event_id, group: group), notice: 'Rsvp was confirmed.') }
        format.xml  { render xml: @rsvp }
      else
        format.html { redirect_to confirm_rsvps_path(@rsvp.event_id, group: group), notice: 'Something went wrong.' }
        format.xml  { render xml: @rsvp.errors, status: :unprocessable_entity }
      end
    end
  end

  def unconfirm
    @rsvp = Rsvp.find(params[:id])
    @rsvp.update_attribute :confirmed, Rsvp::Unconfirmed # TODO (jonko)

    group = params[:group] || "candidates"

    respond_to do |format|
      format.html { redirect_to(confirm_rsvps_path(@rsvp.event_id, group: group), notice: 'Confirmation was removed.') }
      format.xml { render xml: @rsvp }
    end
  end

  def reject
    @rsvp = Rsvp.find(params[:id])
    @rsvp.update_attribute :confirmed, Rsvp::Rejected # TODO (jonko)

    group = params[:group] || "candidates"

    respond_to do |format|
      format.html { redirect_to(confirm_rsvps_path(@rsvp.event_id, group: group), notice: 'Confirmation was rejected.') }
      format.xml { render xml: @rsvp }
    end
  end

  def my_rsvps
    @rsvps = @current_user.rsvps
  end

private

  def validate_owner!(rsvp)
    unless @current_user == rsvp.person || @auth['superusers']
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

  def rsvp_permission
    if !@event.allows_rsvps? or !@event.can_rsvp? @current_user
      redirect_to :root, notice: "You do not have permission to RSVP for this event"
      return false
    end
  end

  def rsvp_params
    params.require(:rsvp).permit(
      :comment,
      :transportation
    )
  end

end
