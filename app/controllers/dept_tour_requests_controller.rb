class DeptTourRequestsController < ApplicationController
  before_filter :authorize_deprel
  # GET /dept_tour_requests
  # GET /dept_tour_requests.xml
  def index
    @dept_tour_requests = DeptTourRequest.all
    @dept_tour_requests_pending = DeptTourRequest.where(responded: true)
    @dept_tour_requests_unresponded = DeptTourRequest.where(responded: false)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dept_tour_requests }
    end
  end

  # GET /dept_tour_requests/1
  # GET /dept_tour_requests/1.xml
  def show
    @dept_tour_request = DeptTourRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dept_tour_request }
    end
  end

  # GET /dept_tour_requests/new
  # GET /dept_tour_requests/new.xml
  def new
    @dept_tour_request = DeptTourRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dept_tour_request }
    end
  end

  # GET /dept_tour_requests/1/edit
  def edit
    @dept_tour_request = DeptTourRequest.find(params[:id])
    @dept_tour_request.date = @dept_tour_request.date.in_time_zone("Pacific Time (US & Canada)").strftime("%Y-%m-%d %I:%M %P")
  end

  # POST /dept_tour_requests
  # POST /dept_tour_requests.xml
  def create
    @dept_tour_request = DeptTourRequest.new(dept_tour_request_params)

    respond_to do |format|
      if @dept_tour_request.save
        format.html { redirect_to(@dept_tour_request, :notice => 'Dept tour request was successfully created.') }
        format.xml  { render :xml => @dept_tour_request, :status => :created, :location => @dept_tour_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dept_tour_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dept_tour_requests/1
  # PUT /dept_tour_requests/1.xml
  def update
    @dept_tour_request = DeptTourRequest.find(params[:id])

    respond_to do |format|
      if @dept_tour_request.update_attributes(dept_tour_request_params)
        format.html { redirect_to(@dept_tour_request, :notice => 'Dept tour request was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dept_tour_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dept_tour_requests/1
  # DELETE /dept_tour_requests/1.xml
  def destroy
    @dept_tour_request = DeptTourRequest.find(params[:id])
    @dept_tour_request.destroy

    respond_to do |format|
      format.html { redirect_to(dept_tour_requests_url, :notice=>"The request has been dismissed. I hope you're happy.") }
      format.xml  { head :ok }
    end
  end
  
  # POST /dept/tour/requests/1/respond
  def respond
    @dept_tour_request = DeptTourRequest.find(params[:id])
    @dept_tour_request.responded = true
    @dept_tour_request.save!
    
    mail = DeptTourMailer.dept_tour_response_email(@dept_tour_request, params[:response], params[:from], params[:ccs])
    mail.deliver
    redirect_to :dept_tour_requests, :notice=>"Your response has been sent."
  end

  private

    def dept_tour_request_params
      params.require(:dept_tour_request).permit(
        :name,
        :date,
        :contact,
        :phone,
        :comments
      )
    end

end
