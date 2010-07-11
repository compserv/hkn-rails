class Admin::TutorAdminController < ApplicationController
  def index
  end

  def signup_slots
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 1 2 3 4)
    @rows = ["Hours"] + @hours
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
