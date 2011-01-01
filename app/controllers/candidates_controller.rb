class CandidatesController < ApplicationController
  before_filter :is_candidate?
  
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
    @announcements = Announcement.order("created_at desc").limit(10)
    requirements = @current_user.candidate.requirements_status
    @status = requirements[:status]
    @rsvps = requirements[:rsvps]
  end

  def application
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
end
