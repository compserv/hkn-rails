class PeopleController < ApplicationController
  before_filter :authorize, :only => [:list, :show, :edit, :update, :groups, :groups_update]
  before_filter :authorize_superuser, :only => [:destroy, :groups_update]
  before_filter :authorize_vp, :only => [:approve]
  before_filter :authorize_comms, :only => [:groups]

  def list
    @category = params[:category] || "all"

    # Can view a group if:
    #   (1) you're a superuser
    #   (2) you're in it
    #   (3) it's a public group      (  vvv      one of these      vvv        )
    unless @auth['superusers'] or (%w[officers cmembers members candidates all] | @current_user.groups.collect(&:name)).include?(@category)
      @messages << "No category named #{@category}. Displaying all people."
      @category = "all"
    end

    order = params[:sort] || "first_name"
    sort_direction = case params[:sort_direction] 
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end

    @search_opts = {'sort' => "first_name"}.merge params
    opts = { :page     => params[:page],
             :per_page => params[:per_page] || 20,
             :order    => "people.#{order} #{sort_direction}"
           }
    if %w[officers].include? @category
      opts.merge!( { :joins => "JOIN committeeships ON committeeships.person_id = people.id", :conditions => ["committeeships.semester = ? AND committeeships.title = ?", Property.semester, @category[0..-2]] } )
    elsif @category != "all"
      @group = Group.find_by_name(@category)
      opts.merge!( { :joins => "JOIN groups_people ON groups_people.person_id = people.id", :conditions => ["groups_people.group_id = ?", @group.id] } )
    end

    person_selector = Person
    if @auth["vp"] and params[:not_approved]
      person_selector = person_selector.where(:approved => nil )
    end

    @people = person_selector.paginate opts

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
    @person = Person.new(params[:person])

    # defaults to making a candidate
    @person.groups << Group.find_by_name("candidates")
    @person.groups << Group.find_by_name("candplus")
    
    #Create new candidate corresponding to this person
    @candidate = Candidate.new
    @candidate.person = @person
    @candidate.save

    if verify_recaptcha(:message=>"Captcha validation failed", :model=>@person) && @person.save
      flash[:notice] = "Account registered!"
      redirect_to root_url
    else
      render :action => "new"
    end
  end

  def show
    @person = Person.find_by_username(params[:login])
    if @person == nil
      if params[:login].to_i != 0
        @person = Person.find(params[:login].to_i) #Find by id
      end
      if @person == nil        
        redirect_to :root, :notice => "The person you tried to view does not exist."
        return
      end
    end
    @badges = @person.badges
  end

  def edit
    if !params[:id].nil? and @current_user.in_group?("superusers")
      @person = Person.find(params[:id])
    else
      @person = @current_user
    end
  end

  def approve
    @person = Person.find(params[:id])
    @person.approved = true
    @person.save

    AccountMailer.account_approval(@person).deliver
    redirect_to :action => "show"
  end

  def update
    @person = Person.find(params[:id])

    # Permissions
    if @person.id != @current_user.id and !@current_user.in_group?("superusers")
      flash[:notice] = "Could not update settings."
      redirect_to account_settings_path
    end

    # Superusers can edit anyone
    if @current_user.in_group?("superusers")
      path = edit_person_path(@person)
    else
      path = account_settings_path
    end
	
    # Verify password
    if params[:password][:current]
      if @current_user.valid_ldap_or_password?(params[:password][:current])
        params[:person][:password] = params[:password][:new]
        params[:person][:password_confirmation] = params[:password][:confirm]
      else
        redirect_to(path, :notice => "You must enter in your current password to make any changes.")
        return
      end
    end

    # DO IT
    if @person.update_attributes(params[:person])
      redirect_to(path, :notice => 'Settings successfully updated.')
    else
      redirect_to(path, :notice => 'Settings could not be updated.')
    end
  end

  def destroy
  end

  def groups
    @person = (Person.find(params[:id]) rescue nil) || (Person.find_by_username(params[:id]) rescue nil)
    unless @person
      flash[:notice] = "Invalid id #{params[:id]}"
      return redirect_to people_list_path
    end
    @allow_edit = can_edit_profile?(@person)
  end

  def groups_update
    unless @person = Person.find(params[:id])
      flash[:notice] = "Invalid id #{params[:id]}"
      return redirect_to people_list_path
    end

    params[:groups] ||= ""
    errors = []
    @person.groups = []
    params[:groups].split.each do |group|
      group.downcase!
      unless group = Group.find_by_name(group)
        errors << "bad group #{group}"
      end
      @person.groups.push(group)
    end

    if errors.empty? and @person.save
      flash[:notice] = "ok"
    else
      flash[:notice] = "Error #{errors.join(', ').inspect}"
    end

    render :action => :groups
  end

  private
  def can_edit_profile?(person)
    # @current_user can view @person if:
    #   1) they're the same person
    #   2) @current_user is a superuser
    @current_user && @current_user.id == params[:id] or @auth['superusers']
  end
end
