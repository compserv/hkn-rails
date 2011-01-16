class ContactsController < ApplicationController
  before_filter :authorize_indrel

  # GET /contacts
  # GET /contacts.xml
  def index
    per_page = 20
    order = params[:sort] || "name"
    sort_direction = case params[:sort_direction]
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end

    @search_opts = {'sort' => "name"}.merge params
    opts = { :page => params[:page], :per_page => per_page, :order => "#{order} #{sort_direction}" }

    if params[:sort] == "companies.name"
      opts.merge!( { :joins => "LEFT OUTER JOIN companies ON companies.id = contacts.company_id" } )
    end
    @contacts = Contact.paginate opts

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
      format.js {
        render :partial => 'list'
      }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @contact = Contact.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/1/edit
  def edit
    @contact = Contact.find(params[:id])
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save
        flash[:notice] = 'Contact was successfully created.'
        format.html { redirect_to(@contact) }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:id])
    @contact.update_attributes(params[:contact])

    respond_to do |format|
      if @contact.errors.size == 0
        flash[:notice] = 'Contact was successfully updated.'
        format.html { redirect_to(@contact) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end
end
