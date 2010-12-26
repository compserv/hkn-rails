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
end
