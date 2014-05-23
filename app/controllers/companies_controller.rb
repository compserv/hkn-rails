class CompaniesController < ApplicationController
  before_filter :authorize_indrel

  # GET /companies
  # GET /companies.xml
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

    @companies = Company.order("#{order} #{sort_direction}").paginate opts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @companies }
      format.js {
        render :partial => 'list'
      }
    end
  end

  # GET /companies/1
  # GET /companies/1.xml
  def show
    @company = Company.find(params[:id])
    @contacts = @company.contacts

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /companies/new
  # GET /companies/new.xml
  def new
    @company = Company.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @company }
    end
  end

  # GET /companies/1/edit
  def edit
    @company = Company.find(params[:id])
  end

  # POST /companies
  # POST /companies.xml
  def create
    @company = Company.new(company_params)

    respond_to do |format|
      # Save without logging in as the company
      if @company.save_without_session_maintenance
        flash[:notice] = 'Company was successfully created.'
        format.html { redirect_to(@company) }
        format.xml  { render :xml => @company, :status => :created, :location => @company }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /companies/1
  # PUT /companies/1.xml
  def update
    @company = Company.find(params[:id])

    respond_to do |format|
      if @company.update_attributes(company_params)
        flash[:notice] = 'Company was successfully updated.'
        format.html { redirect_to(@company) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @company.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1
  # DELETE /companies/1.xml
  def destroy
    @company = Company.find(params[:id])
    @company.destroy

    respond_to do |format|
      format.html { redirect_to(companies_url) }
      format.xml  { head :ok }
    end
  end

  def reset_access
    unless company = Company.find(params[:id])
      return redirect_to companies_path, :notice => "Invalid company id #{params[:id]}"
    end

    notice = []

    if sesh = CompanySession.find(company) and sesh.destroy and CompanySession.new(company)
      notice << "Session invalidated"
    else
      notice << "INFO: No session found to invalidate"
    end

    notice << if company.reset_single_access_token!
      "Successfully reset access key"
    else
      "ERROR: Failed to reset access key"
    end
    redirect_to companies_path, :notice => notice.join('; ')  # <br> y u no work
  end

  private

    def company_params
      params.require(:company).permit(
        :name,
        :address,
        :website,
        :comments
      )
    end

end
