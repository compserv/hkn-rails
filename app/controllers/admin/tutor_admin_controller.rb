class Admin::TutorAdminController < ApplicationController
  def index
  end

  def signup_slots
    if UserSession.find
      @current_user = UserSession.find.person
    end
    if @current_user.nil?
      @message = "You must log in to set your tutoring availabilities"
    end
    if @current_user.tutor.nil?
      @current_user.tutor = Tutor.new
      @current_user.tutor.availability = Availability.new
      @current_user.tutor.save
      @current_user.tutor.availability.save
    end
    tutor = @current_user.tutor
    @slots = tutor.availability.slots
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 13 14 15 16)
    @rows = ["Hours"] + @hours
  end

  def post_slots
    p params
  end
  
  def signup_classes
  end

  def generate_schedule
  end

  def view_signups
  end

  def edit_schedule
  end

  def settings
  end

end
