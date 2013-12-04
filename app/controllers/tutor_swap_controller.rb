class TutorSwapController < ApplicationController
  before_filter :require_login  # check if user is logged in
  before_filter :require_tutor  # check if logged-in user is a valid tutor
  before_filter :setup, :only => [:new, :create]

  def require_login # check if logged in, otherwise redirect
    return if logged_in
    redirect_to login_path
  end

  def logged_in # return whether or not logged in
    @current_user
  end

  def require_tutor # check if valid tutor, otherwise redirect
    return if valid_tutor
    redirect_to tutor_path
  end

  def valid_tutor # return whether or not logged-in person is valid tutor
    Tutor.find_by_person_id(@current_user.id) != nil
  end

  def setup # setup list of slots to display when creating swap
    @mytutor = Tutor.find_by_person_id(@current_user.id)
    
    @myslots = []
    Slot.all.each do |s|
      if s.tutors.include?(@mytutor)
        @myslots << s
      end
    end
    return true
  end

  def new # initialize new TutorSwap
    setup
    @newswap = TutorSwap.new
  end

  def create  # instantiate new TutorSwap and save
    @mytutor = Tutor.find_by_person_id(@current_user.id)
    
    @myslots = []
    Slot.all.each do |s|
      if s.tutors.include?(@mytutor)
        @myslots << s
      end
    end

    @newswap = TutorSwap.new

    swap_slot = Slot.find_by_id(params[:slot][:slot_id])  # slot that is supposed to be swapped

    # check if submitted name is actually a person
    @newswap.orig_tutor_id = @mytutor.id    # ASSIGN TutorSwap.orig_tutor_id
    first = params[:tutor].split(" ")[0]
    last = params[:tutor].split(" ")[1]
    flash[:notice] = params[:tutor]
    new_tutor_person = Person.find_by_first_name_and_last_name(first, last)
    unless new_tutor_person
      flash[:notice] = "#{first}|#{last}"
      # flash[:notice] = "The person you have specified does not exist"
      redirect_to :action => :new
      return
    end

    # check if specified person is a valid tutor
    new_tutor = Tutor.find_by_person_id(new_tutor_person.id)
    unless new_tutor
      flash[:notice] = "The person you have specified is not a tutor"
      redirect_to :action => :new
      return
    end
    
    # check if specified person is the same as the submitting person
    unless new_tutor != @mytutor
      flash[:notice] = "You cannot swap tutoring slots with yourself"
      redirect_to :action => :new
      return
    end

    # check if specified tutor has a conflicting slot, i.e. same time
    Slot.all.each do |s|
      if s.tutors.include?(new_tutor)
        if s.wday == swap_slot.wday && s.hour == swap_slot.hour
          flash[:notice] = "Tutor has a conflicting slot"
          redirect_to :action => :new
          return
        end
      end
    end

    @newswap.new_tutor_id = new_tutor.id    # ASSIGN TutorSwap.new_tutor_id

    @newswap.slot_id = params[:slot][:slot_id]  # ASSIGN TutorSwap.slot_id

    # reformat inputted date string
    date = Date.today
    begin
      date = Date.strptime(params[:date], "%m/%d/%Y")
    rescue ArgumentError
      flash[:notice] = "Date is formatted incorrectly"
      redirect_to :action => :new
      return
    end

    @newswap.swap_date = date   # ASSIGN TutorSwap.swap_date

    @newswap.save   # SAVE TutorSwap

    # finish
    flash[:notice] = "Swap submitted!"
    redirect_to :action => :new
  end

  def to_s
    "TutorSwap #{orig_tutor_id} #{new_tutor_id} #{slot_id}"
  end

end
