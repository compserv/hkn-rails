class AlumnisController < ApplicationController
  before_filter :alumni_login_check
  before_filter :alumni_duplication_filtration, :only => [:new,:create]
  before_filter :alumni_modification_authorization_filtration, :only=> [:edit, :update, :destroy]
  before_filter :authorize_alumrel, :only => :index
  before_filter :input_helper, :only => [:update,:create,]
  
  def alumni_login_check
    redirect_to(login_url, :notice=>"You must log in to edit alumni information.") if not @current_user
  end
  
  def alumni_duplication_filtration
    if @current_user.alumni
      redirect_to(@current_user.alumni, 
                  :notice => "You already have an alumni record. I've helpfully brought it up for you.")
    end
  end
  
  def alumni_modification_authorization_filtration
    @alumni = Alumni.find_by_id(params[:id])
    unless @alumni and @current_user.alumni == @alumni or @auth['alumrel']
      redirect_to(if @current_user.alumni then edit_alumni_url(@current_user.alumni) 
                    else new_alumni_url end, 
                  :notice => "You're not authorized to modify someone else's alumni information!")
    end
  end
  
  def input_helper
    #Allow leading $, and seperators of , and _ (strip them)
    params[:alumni][:salary].gsub!(/(^\$)|,|_/,'') if params[:alumni] && params[:alumni][:salary]
  end
  
  def me 
    if @current_user.alumni
      @alumni = @current_user.alumni
      render "show"
    else
      redirect_to new_alumni_url
    end
  end
  
  # GET /alumnis
  # GET /alumnis.xml
  def index
    @alumnis = Alumni.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @alumnis }
    end
  end

  # GET /alumnis/1
  # GET /alumnis/1.xml
  def show
    @alumni = Alumni.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @alumni }
    end
  end

  # GET /alumnis/new
  # GET /alumnis/new.xml
  def new
    @alumni = Alumni.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @alumni }
    end
  end

  # GET /alumnis/1/edit
  def edit
    # not strictly needed
    @alumni = Alumni.find_by_id(params[:id])
    grad_semester = @alumni.grad_semester.split
    @grad_season = grad_semester[0] # Spring or Fall
    @grad_year = grad_semester[1] # the actual year
  end

  # POST /alumnis
  # POST /alumnis.xml
  def create
    @alumni = Alumni.new(alumni_params)
    @alumni.grad_semester = Alumni.grad_semester(params[:grad_season], params[:grad_year])
    # params[:grad_season] is Spring or Fall
    # params[:grad_year] is the actual year
    # This is so hacky. grad_season and grad_year are separate from the
    # other Alumni attributes when we're processing the form input because
    # it would be silly to have grad_season, grad_year, and grad_semester
    # when grad_semester is just the concatenation of grad_season and grad_year.
    # Similar funny business in update.
    respond_to do |format|
      if @alumni.save and @current_user.save
        if @alumni.mailing_list
          @alumni.subscribe
        end
 
        format.html { redirect_to(@alumni, :notice => 'Alumni was successfully created.') }
        format.xml  { render :xml => @alumni, :status => :created, :location => @alumni }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @alumni.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /alumnis/1
  # PUT /alumnis/1.xml
  def update
    @alumni = Alumni.find(params[:id])

    respond_to do |format|
      # params[:grad_season] is Spring or Fall
      if @alumni.update_attributes(alumni_params.merge(
        :grad_semester => Alumni.grad_semester(params[:grad_season], params[:grad_year])
      ))
        if !@alumni.mailing_list && params[:on_mailing_list].eql?('true')
          @alumni.unsubscribe
        elsif @alumni.mailing_list && params[:on_mailing_list].eql?('false')
          @alumni.subscribe
        end

        format.html { redirect_to(@alumni, :notice => 'Alumni was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @alumni.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /alumnis/1
  # DELETE /alumnis/1.xml
  def destroy
    @alumni = Alumni.find(params[:id])
    @alumni.destroy

    respond_to do |format|
      format.html { redirect_to (if @auth['alumrel'] then alumnis_url else root_url end), 
                      :notice=> "Alumni information for #{@alumni.person.full_name} destroyed."}
      format.xml  { head :ok }
    end
  end

  private

    def alumni_params
      params.require(:alumni).permit(
        :person_id,
        :perm_email,
        :mailing_list,
        :grad_school,
        :job_title,
        :company,
        :salary,
        :location,
        :suggestions
      )
    end

end
