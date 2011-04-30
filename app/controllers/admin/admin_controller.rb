class Admin::AdminController < ApplicationController
  #before_filter :authorize_officers, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]
  before_filter :authorize_comms, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]

    ELECTION_DETAILS = {
      :person   => [ #:username,        # this isn't working atm
                    :phone_number, 
                    :aim,          
                    :email,        
                    :local_address,
                    :date_of_birth ],
      :election => [:txt,            
                    :sid,            
                    :keycard,        
                    :midnight_meeting ]
    }

  def election_details
    @user = @current_user
    @election = @current_user.current_election
    @details = ELECTION_DETAILS

    Election.find_or_create_by_person_id_and_semester(@user.id, Property.current_semester)
  end

  def update_election_details
    obj, pheedback = nil, []
    if params[:election].present? then
        pheedback << "Post-election info"
        pheedback << (obj=@current_user.current_election).update_attributes(params[:election])
    elsif params[:person].present? then
        obj = @current_user

        # Need to reset crypted password if username changed
        unless params[:person][:username] == obj.username
            obj.change_username :username => params[:person][:username], :password => params[:person][:password]
        end
        params[:person].delete :password
        params[:person].delete :username

        pheedback << "User profile"
        pheedback << obj.valid? && obj.update_attributes(params[:person])
    else
        # wat happened?
        redirect_to admin_general_election_details_path
    end

    pheedback.push({true=>"updated successfully.", false=>"failed because #{obj.errors.to_a.to_ul}"}[pheedback.pop])
    pheedback = pheedback * ' '

    redirect_to admin_general_election_details_path, :notice => pheedback
  end

  def super_page
    @candidates = Candidate.find(:all, :joins => :person, :order => "people.first_name, people.last_name")
    @candidates.map! { |cand|
      calculate_status(cand)    
    }

    #puts @candidates
  end

  def calculate_status(cand)
    #puts cand
    done = Hash.new(false)

    if cand.person_id == nil
      done["events"] = []
      return done
    end
    done["candidate"] = cand.person.full_name
    done["events"] = cand.requirements_count 

    #puts "REQ COUNT"
    #puts cand.requirements_count
    #puts "=="
    done["challenges"] = cand.challenges.select {|c| c.status }.length
    done["unconfirmed_challenges"] = cand.challenges.where :status => nil
    done["confirmed_challenges"] = cand.challenges.where :status => true
    done["resume"] = cand.person.resumes.length
    done["quiz"] = cand.quiz_score
    done["quiz_responses"] = Hash[cand.quiz_responses.map{|x| [x.number.to_sym, {:response => x.response, :correct => x.correct}]}]
    done["course_surveys"] = false

    #puts done.to_s
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
