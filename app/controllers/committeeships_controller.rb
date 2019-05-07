class CommitteeshipsController < ApplicationController
  before_filter :authorize_rsec, only: [:create, :destroy, :index]
  before_filter :get_person

  def get_person
    @person = Person.find_by_id(params[:id])
  end

  def index
  end

  def create
    @committeeship = Committeeship.new
    @committeeship.semester = Property.current_semester
    @committeeship.title = params[:committeeship][:title]
    @committeeship.person = Person.find_by_id(params[:id])
    @committeeship.committee = params[:committeeship][:committee]
    if @committeeship.save
      flash[:notice] = "Successfully added as #{@committeeship.nice_committee} #{@committeeship.nice_title}"
    else
      flash[:notice] = "Error in adding #{@committeeship.nice_title}"
    end
    redirect_to person_url(@committeeship.person)
  end

  def destroy
    @committeeship = Committeeship.find(params[:id])
    if (@auth['rsec'])
      @committeeship.destroy
      flash[:notice] = "Successfully deleted the committeeship"
    else
      flash[:notice] = "You do not have the authorization to do that."
    end
    redirect_to person_url(@committeeship.person)
  end
end
