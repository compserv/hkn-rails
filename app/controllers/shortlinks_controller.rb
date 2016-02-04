class ShortlinksController < ApplicationController
  before_action :set_shortlink, only: [:show, :edit, :update, :destroy]

  # GET /shortlinks
  def index
    @shortlinks = Shortlink.all
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shortlink
      @shortlink = Shortlink.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def shortlink_params
      params.require(:shortlink).permit(:in_url, :out_url, :http_status)
    end
end
