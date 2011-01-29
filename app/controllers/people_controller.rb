class PeopleController < ApplicationController
  before_filter :authorize, :only => [:list, :show, :edit, :update]
  before_filter :authorize_superuser, :only => [:destroy]
  
  [:list, :show].each {|a| caches_action a, :layout => false}

  def list
    @category = params[:category] || "all"

    # Prevent people from seeing members of any group
    unless %w[officers cmembers members candidates all].include? @category
      @messages << "No category named #{@category}. Displaying all people."
      @category = "all"
    end

    per_page = 10
    order = params[:sort] || "first_name"
    sort_direction = case params[:sort_direction] 
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end

    @search_opts = {'sort' => "first_name"}.merge params
    opts = { :page => params[:page], :per_page => 10, :order => "people.#{order} #{sort_direction}" }
    if %w[officers cmembers].include? @category
      opts.merge!( { :joins => "JOIN committeeships ON committeeships.person_id = people.id", :conditions => ["committeeships.semester = ? AND committeeships.title = ?", Property.semester, @category[0..-2]] } )
    elsif @category != "all"
      @group = Group.find_by_name(@category)
      opts.merge!( { :joins => "JOIN groups_people ON groups_people.person_id = people.id", :conditions => ["groups_people.group_id = ?", @group.id] } )
    end
    @people = Person.paginate opts

    respond_to do |format|
      format.html
      format.js {
        render :partial => 'list_results'
      }
    end
  end

  def new
    @hide_topbar = true
    @person = Person.new
  end

  def create
    expire_action :action => :list
    expire_action :action => :show
    
    @person = Person.new(params[:person])
    if params[:candidate] == "true"
      @person.groups << Group.find_by_name("candidates")
      @person.groups << Group.find_by_name("candplus")
      
      #Create new candidate corresponding to this person
      @candidate = Candidate.new
      @candidate.person = @person
      @candidate.save
    else
      @person.groups << Group.find_by_name("members")
      @person.groups << Group.find_by_name("candplus")
    end

    if @person.save
      flash[:notice] = "Account registered!"
      redirect_to root_url
    else
      render :action => "new"
    end
  end

  def show
    @person = Person.find(params[:id])
  end

  def edit
    if !params[:id].nil? and @current_user.in_group?("superusers")
      @person = Person.find(params[:id])
    else
      @person = @current_user
    end
  end

  def update
    expire_action :action => :list
    expire_action :action => :show
    
    @person = Person.find(params[:id])
    if @person.id != @current_user.id and !@current_user.in_group?("superusers")
      flash[:notice] = "Could not update settings."
      redirect_to account_settings_path
    end

    if @current_user.in_group?("superusers")
      path = edit_person_path(@person)
    else
      path = account_settings_path
    end
	
	if params[:password][:current]
	  if @current_user.valid_ldap_or_password?(params[:password][:current])
	    params[:person][:password] = params[:password][:new]
      params[:person][:password_confirmation] = params[:password][:confirm]
	  else
	    raise "Incorrect password"#Figure out how to send this message along as an error
	  end
	end
    if @person.update_attributes(params[:person])
      redirect_to(path, :notice => 'Settings successfully updated.')
    else
      redirect_to(path, :notice => 'Settings could not be updated.')
    end
  end

  def destroy
    expire_action :action => :list
    expire_action :action => :show
  end
end
