class Admin::AdminController < ApplicationController
  #before_filter :authorize_officers, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]
  before_filter :authorize_comms, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]
  
  def candidate_announcements
    @announcements = Announcement.order("created_at desc")
    render "admin/candidate_announcements"
  end
  
  def create_announcement
    a = Announcement.new
    a.title = params[:title]
    a.body = params[:body]
    a.person = @current_user
    saved = a.save
    
    if saved
      flash[:notice] = "Announcement created."
      #render :json => [true]
    else
      flash[:notice] = "Your announcement couldn't be created."
      #render :json => [false, "Error."]
    end
    redirect_to :back
  end
  
  def edit_announcement
    @announcement = Announcement.find(params[:id])
    render "admin/edit_announcement"
  end
  
  def update_announcement
    a = Announcement.find(params[:id])
    a.title = params[:title]
    a.body = params[:body]
    saved = a.save
    
    if saved
      flash[:notice] = "Announcement updated."
      redirect_to "/admin/general/candidate_announcements"
      #render :json => [true]
    else
      flash[:notice] = "Your announcement couldn't be updated."
      redirect_to :back
      #render :json => [false, "Error."]
    end
    
  end
  
  def delete_announcement
    a = Announcement.find(params[:id])
    a.destroy
    
    flash[:notice] = "Announcement has been deleted."
    redirect_to :back
  end
  
  def confirm_challenges
    challenges = Challenge.find(:all, :conditions => {:officer_id => @current_user.id})
    @acc_challenges = challenges.select {|c| c.status }
    @pending_challenges = challenges.select {|c| !c.status }
    render "admin/confirm_challenges"
  end
  
  def confirm_challenge
    challenge = Challenge.find(params[:id])
    challenge.status = true
    challenge.save
    
    flash[:notice] = "Challenge confirmed."
    redirect_to :back
  end
end
