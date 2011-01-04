class AlumnisController < ApplicationController
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
    @alumni = @current_user.alumni
  end

  # POST /alumnis
  # POST /alumnis.xml
  def create
    @alumni = Alumni.new(params[:alumni])

    respond_to do |format|
      if @alumni.save
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
      format.html { redirect_to(alumnis_url) }
      format.xml  { head :ok }
    end
  end
end
