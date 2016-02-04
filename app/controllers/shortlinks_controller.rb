class ShortlinksController < ApplicationController
  before_action :set_shortlink, only: [:show, :edit, :update, :destroy]
  before_filter :authorize_shortlinks, except: [:go]
  before_filter :authorize_own_shortlink, only: [:edit, :update, :destroy]

  # GET /shortlinks
  def index
    if @auth['superusers']
      @shortlinks = Shortlink.all
    else
      @shortlinks = Shortlink.where(person_id: @current_user.id)
    end
  end

  # GET /shortlinks/1
  def show
  end

  # GET /shortlinks/new
  def new
    @shortlink = Shortlink.new
  end

  # GET /shortlinks/1/edit
  def edit
  end

  # POST /shortlinks
  def create
    @shortlink = Shortlink.new(shortlink_params)
    @shortlink.person = @current_user
    unless @shortlink.out_url.start_with?("http")
      @shortlink.out_url = "http://" + @shortlink.out_url
    end

    if @shortlink.save
      redirect_to @shortlink, notice: 'Shortlink was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /shortlinks/1
  def update
    if @shortlink.update(shortlink_params)
      redirect_to @shortlink, notice: 'Shortlink was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /shortlinks/1
  def destroy
    @shortlink.destroy
    redirect_to shortlinks_url, notice: 'Shortlink was successfully destroyed.'
  end

  # Follow created shortlink, without validation.
  def go
    @link = Shortlink.find_by_in_url!(params[:in_url])
    redirect_to @link.out_url, :status => @link.http_status
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shortlink
      @shortlink = Shortlink.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shortlink_params
      params.require(:shortlink).permit(:in_url, :out_url, :http_status)
    end

    def authorize_shortlinks
      authorize(['officers', 'cmembers'])
    end

    def authorize_own_shortlink
      @shortlink.person == @current_user || @auth['superuser']
    end
end
