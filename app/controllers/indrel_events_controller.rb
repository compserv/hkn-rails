class IndrelEventsController < ApplicationController
  before_filter :authorize_indrel

  # GET /events
  # GET /events.xml
  def index
    per_page = 10
	order = params[:sort] || "time"
	sort_direction = case params[:sort_direction]
						when "up" then "ASC"
						when "down" then "DESC"
						else "DESC"
						end

	@search_opts = {'sort' => "time", 'sort_direction' => "down" }.merge params
	opts = { page: params[:page], per_page: per_page }

	if params[:sort] == "companies.name"
		opts.merge!( { joins: "LEFT OUTER JOIN companies ON companies.id = indrel_events.company_id" } )
	elsif params[:sort] == "locations.name"
		opts.merge!( { joins: "LEFT OUTER JOIN locations ON locations.id = indrel_events.location_id" } )
	elsif params[:sort] == "indrel_event_types.name"
		opts.merge!( { joins: "LEFT OUTER JOIN indrel_event_types ON indrel_event_types.id = indrel_events.indrel_event_type_id" } )
	end
    @events = IndrelEvent.order("#{order} #{sort_direction}").paginate opts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @events }
      format.js {
        render partial: 'list'
      }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = IndrelEvent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = IndrelEvent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = IndrelEvent.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    @event = IndrelEvent.new(indrel_event_params)

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to(@event) }
        format.xml  { render xml: @event, status: :created, location: @event }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    @event = IndrelEvent.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(indrel_event_params)
        flash[:notice] = 'Event was successfully updated.'
        format.html { redirect_to(@event) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = IndrelEvent.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(indrel_events_url) }
      format.xml  { head :ok }
    end
  end

  private

    def indrel_event_params
      params.require(:indrel_event).permit(
        :time,
        :location,
        :indrel_event_type,
        :food,
        :prizes,
        :turnout,
        :company,
        :contact,
        :officer,
        :feedback,
        :comments
      )
    end

end
