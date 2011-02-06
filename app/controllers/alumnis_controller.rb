class AlumnisController < ApplicationController
  before_filter :alumni_login_check
  before_filter :alumni_duplication_filtration, :only => [:new,:create]
  before_filter :alumni_modification_authorization_filtration, :only=> [:edit, :update, :destroy]
  before_filter :authorize_alumrel, :only => :index
  
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
  end

  # POST /alumnis
  # POST /alumnis.xml
  def create
    @alumni = Alumni.new(params[:alumni])
    @current_user.alumni = @alumni

    respond_to do |format|
      if @alumni.save and @current_user.save
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
      if @alumni.update_attributes(params[:alumni])
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
end
