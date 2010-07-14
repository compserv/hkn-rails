class Admin::TutorAdminController < ApplicationController
  before_filter {|controller| controller.send(:authorize, "tutoring")}
  def index
  end

  def signup_slots
    tutor = @current_user.get_tutor
    @prefs = {}
    tutor.availabilities.each {|a| @prefs[a.slot.to_s] = a.preference_level}
    @messages ||= []
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
    @slots = Slot.all
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 13 14 15 16)
    @rows = ["Hours"] + @hours
  end

  def settings
  end

end
