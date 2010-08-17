class PeopleController < ApplicationController

  def list
    @category = params[:category] || "all"

    # Prevent people from seeing members of any group
    unless %w[officers members candidates all].include? @category
      flash[:notice] = "No category named #{@category}. Displaying all people."
      @category = "all"
    end

    if @category == "all"
      @people = Person.find(:all)
    else
      @group = Group.find_by_name(@category)
      @people = @group.people
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
