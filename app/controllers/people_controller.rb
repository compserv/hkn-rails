class PeopleController < ApplicationController
  before_filter :authorize, :only => [:list]

  def list
    @category = params[:category] || "all"

    # Prevent people from seeing members of any group
    unless %w[officers members candidates all].include? @category
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
    unless @category == "all"
      @group = Group.find_by_name(@category)
      opts.merge!( { :joins => "JOIN groups_people ON groups_people.person_id = people.id", :conditions => ["groups_people.group_id = ?", @group.id] } )
    end
    @people = Person.paginate opts

    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.replace 'results', :partial => 'list_results'
        end
      }
    end
  end

  def new
    @hide_topbar = true
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if params[:candidate] == "true"
      @person.groups << Group.find_by_name("candidates")
    else
      @person.groups << Group.find_by_name("members")
    end

    if @person.save
      flash[:notice] = "Account registered!"
      redirect_to root_url
    else
      render :action => "new"
    end
  end
end
