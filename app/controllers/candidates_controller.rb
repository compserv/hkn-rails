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
  end

end
