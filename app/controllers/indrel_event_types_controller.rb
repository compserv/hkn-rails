class IndrelEventTypesController < ApplicationController
  before_filter :authorize_indrel

  # GET /event_types
  # GET /event_types.xml
  def index
    per_page = 20
    order = params[:sort] || "name"
    sort_direction = case params[:sort_direction]
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end

    @search_opts = {'sort' => "name"}.merge params
    opts = { :page => params[:page], :per_page => per_page }
    @event_types = IndrelEventType.order("#{order} #{sort_direction}").paginate opts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @event_types }
      format.js {
        render :partial => 'list'
      }
    end
  end

  # GET /event_types/1
  # GET /event_types/1.xml
  def show
    @event_type = IndrelEventType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event_type }
    end
  end

  # GET /event_types/new
  # GET /event_types/new.xml
  def new
    @event_type = IndrelEventType.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event_type }
    end
  end

  # GET /event_types/1/edit
  def edit
    @event_type = IndrelEventType.find(params[:id])
  end

  # POST /event_types
  # POST /event_types.xml
  def create
    @event_type = IndrelEventType.new(indrel_event_type_params)

    respond_to do |format|
      if @event_type.save
        flash[:notice] = 'IndrelEventType was successfully created.'
        format.html { redirect_to(@event_type) }
        format.xml  { render :xml => @event_type, :status => :created, :location => @event_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /event_types/1
  # PUT /event_types/1.xml
  def update
    @event_type = IndrelEventType.find(params[:id])

    respond_to do |format|
      if @event_type.update_attributes(indrel_event_type_params)
        flash[:notice] = 'IndrelEventType was successfully updated.'
        format.html { redirect_to(@event_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /event_types/1
  # DELETE /event_types/1.xml
  def destroy
    @event_type = IndrelEventType.find(params[:id])
    @event_type.destroy

    respond_to do |format|
      format.html { redirect_to(indrel_event_types_url) }
      format.xml  { head :ok }
    end
  end

  private

    def indrel_event_type_params
      params.require(:indrel_event_type).permit(
        :name
      )
    end

end
