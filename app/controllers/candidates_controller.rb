class CandidatesController < ApplicationController
  before_filter :is_candidate?, :except => [:promote]
  before_filter :authorize_vp, :only => [:promote]
  
  def is_candidate?
    if @current_user
      if !@current_user.in_group?("candidates")
        flash[:notice] = "You're not a candidate anymore, so this information may not apply to you"
      end
      return true
    else
      flash[:notice] = "You must be logged in to view that page."
      redirect_to "/"
    end
  end

  def portal
    if(@current_user.candidate)
      @announcements = Announcement.order("created_at desc").limit(10)
      requirements = @current_user.candidate.requirements_status
      @status = requirements[:status]
      @rsvps = requirements[:rsvps]
      @events = Event.upcoming_events(5, @current_user)
    
      @done = Hash.new(false) #events, challenges, forms, resume, quiz, course_surveys
    
      @done["events"] = !@status.has_value?(false)
      @done["challenges"] = @current_user.candidate.challenges.select {|c| c.status }.length >= 5
      @done["resume"] = @current_user.resumes.length >= 0
      @done["quiz"] = @current_user.candidate.quiz_responses.length >= 0
      @done["forms"] = @done["resume"] and @done["quiz"]
      @done["course_surveys"] = false

      @coursesurveys_active = Property.get_or_create.coursesurveys_active
      @required_surveys = Candidate.required_surveys
      @coursesurveys = @current_user.coursesurveys
    else
      flash[:notice] = "Oops, there's no candidate information for your account."
      redirect_to :back
    end

  end
  
  def find_officers #FIXME: what's a more efficient way to do this?
    render :json => Person.all.select {|p| p.in_group?("comms")}.map {|p| p.first_name + " " + p.last_name}
  end

  def application
    if(@current_user.candidate)
      @app_details = {
        :aim => @current_user.aim, 
        :phone => @current_user.phone_number,
        :local_address => @current_user.local_address,
        :perm_address => @current_user.perm_address,
        :grad_sem => @current_user.grad_semester,
        :release => @current_user.candidate.release,
        :committee_prefs => !@current_user.candidate.committee_preferences ? Candidate.committee_defaults : @current_user.candidate.committee_preferences.split,
        :suggestion => @current_user.suggestion ? @current_user.suggestion.suggestion : ""
      }
    else
      flash[:notice] = "Oops, there's no candidate information for your account."
      redirect_to :back
    end
    
  end

  def quiz
    quiz_resp = @current_user.candidate.quiz_responses
    @quiz_resp = Hash.new("")
    if !quiz_resp.empty? #Fill hash with default blanks
      for resp in quiz_resp
        @quiz_resp[resp.number.to_sym] = resp.response
      end
    end
      
  end
  
  def request_challenge
    officer_name = params[:officer].split
    challenge_name = params[:name]
    
    #is there a better way to look up a person like this?
    officer = Person.find(:first, :conditions => {:first_name => officer_name[0], :last_name => officer_name[1]})
    if(!officer or !officer.in_group?("officers")) #If officer does not exist
      render :json => [false, "Invalid officer."]
      return
    elsif(challenge_name == "") #challenge name is blank
       render :json => [false, "Challenge name is blank."]
       return
    end
    
    challenge = Challenge.new(:name => challenge_name, :status => nil, :officer_id => officer.id)
    challenge.candidate = @current_user.candidate
    saved = challenge.save
    
    if(!saved) #challenge didn't save for some reason
      render :json => [false, "Oops, something went wrong!"]
      return
    end
    
    render :json => [true, challenge.id]
  end
  
  def update_challenges
    render :partial => "challenges"
  end

  def submit_quiz
    params.each do |key, value|
      if key.match(/^q/) #Starts with "q", is a quiz response
        quiz_resp = @current_user.candidate.quiz_responses
        q = nil
        if quiz_resp.empty? #No quiz responses for this candidate, create
          q = QuizResponse.new(:number => key.to_s)
          q.candidate = @current_user.candidate
        else #Update existing quiz responses
          q = quiz_resp.select {|x| x.number == key.to_s}.first      
        end
          q.response = value.to_s
          q.save
      end
    end
    flash[:notice] = "Your quiz responses have been recorded."
    redirect_to :back
  end
  
  def submit_app
    @current_user.update_attributes({
      :aim => params[:aim],
      :phone_number => params[:phone],
      :local_address => params[:local_address],
      :perm_address => params[:perm_address],
      :grad_semester => params[:grad_sem]
    })
    
    @current_user.candidate.update_attributes({
      :committee_preferences => params[:committee_prefs],
      :release => params[:release] ? true : false
    })
    
    suggestion = @current_user.suggestion
    if(@current_user.suggestion) #already has a suggestion, edit
      suggestion.suggestion = params[:suggestion]
      suggestion.save
    else #create a new one
      suggestion = Suggestion.new(:suggestion => params[:suggestion])
      @current_user.suggestion = suggestion
    end
    
    flash[:notice] = "Your application has been saved."
    redirect_to :back
  end

  def coursesurvey_signup
    @remaining_surveys = Candidate.required_surveys - @current_user.coursesurveys.count
    @coursesurveys = Coursesurvey.current_semester
  end

  def coursesurvey_signup_post
    param_ids = params.keys.reject{|x| !(x =~ /^survey[0-9]*$/)}

    # Don't allow more than 3 surveys
    return redirect_to coursesurvey_signup_path, :notice => "You can sign up for a maximum of three classes." if (@current_user.coursesurveys.count+param_ids.count) > 3

    param_ids.each do |param_id|
      id = param_id[6..-1]
      coursesurvey = Coursesurvey.find(id)

      if @current_user.coursesurveys.include? coursesurvey
        redirect_to(coursesurvey_signup_path, :notice => "You are already signed up for one or more classes you selected.")
        return
      end

      if coursesurvey.full?
        redirect_to(coursesurvey_signup_path, :notice => "One or more classes you selected are full.")
        return
      end

      @current_user.coursesurveys << coursesurvey
    end
    redirect_to(candidate_portal_path, :notice => "Signed up for surveys.")
  end

  def promote
      @cand = Person.find_by_id(params[:id])
      member_group = Group.find_by_name('members')
      candidate_group = Group.find_by_name('candidates')
      if @cand.groups.include?(candidate_group)
          @cand.groups.delete(candidate_group)
          @cand.groups |= [member_group]
          if @cand.save()
              # good to go
          else
              flash[:notice] = "Changes not saved to db"
          end
      else
          flash[:notice] = "This person is not a member of the candidate group"
      end
      redirect_to "/admin/general/super_page"
  end
end
