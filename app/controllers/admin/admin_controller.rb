class Admin::AdminController < ApplicationController
  #before_filter :authorize_officers, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]
  before_filter :authorize_comms, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]

  def super_page
	@candidates = Candidate.all
	@candidates.map! { |cand|
	    calculate_status(cand)    
	}

	puts @candidates
  end
  
  def calculate_status(cand)
	puts cand
	done = Hash.new(false)

	if cand.person_id == nil
		done["events"] = []
		return done
	end
        done["candidate"] = cand.person.full_name
	done["events"] = cand.requirements_count 

	puts "REQ COUNT"
	puts cand.requirements_count
	puts "=="
	done["challenges"] = cand.challenges.select {|c| c.status }.length
	done["resume"] = cand.person.resumes.length
	done["quiz"] = cand.quiz_responses.length
	done["course_surveys"] = false
	
	puts done.to_s
	return done
  end 

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
    @pending_challenges = challenges.select {|c| c.status == nil }
    @rejected_challenges = challenges.select {|c| c.status == false}
    render "admin/confirm_challenges"
  end
  
  def confirm_challenge
    challenge = Challenge.find(params[:id])
    challenge.status = true
    challenge.save
    
    flash[:notice] = "Challenge confirmed."
    redirect_to :back
  end
  def reject_challenge
    challenge = Challenge.find(params[:id])
    challenge.status = false
    challenge.save
    
    flash[:notice] = "Challenge rejected."
    redirect_to :back
  end
end
