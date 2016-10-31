class LocationsController < ApplicationController
  before_filter :authorize_indrel

  # GET /locations
  # GET /locations.xml
  def index
    per_page = 20
    order = params[:sort] || "name"
    sort_direction = case params[:sort_direction]
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end

    @search_opts = {'sort' => "name"}.merge params
    opts = { page: params[:page], per_page: per_page }

    @locations = Location.order("#{order} #{sort_direction}").paginate opts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @locations }
      format.js {
        render partial: 'list'
      }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = Location.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(location_params)

    respond_to do |format|
      if @location.save
        flash[:notice] = 'Location was successfully created.'
        format.html { redirect_to(@location) }
        format.xml  { render xml: @location, status: :created, location: @location }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(location_params)
        flash[:notice] = 'Location was successfully updated.'
        format.html { redirect_to(@location) }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end

  private

    def location_params
      params.require(:location).permit(
        :name,
        :capacity,
        :comments
      )
    end

end
