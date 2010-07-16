class Admin::TutorController < ApplicationController
  before_filter {|controller| controller.send(:authorize, "tutoring")}
  def index
  end

  def signup_slots
    tutor = @current_user.get_tutor
    @prefs = Hash.new 0
    tutor.availabilities.each {|a| @prefs[a.time.strftime('%a%H')] = a.preference_level}
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 13 14 15 16)
    @rows = ["Hours"] + @hours
    
    if params[:authenticity_token]  #The form was submitted
      changed=false
      params.keys.each do |x|
        daytime = Slot.extract_day_time(x)
        if daytime
          pref = Availability.prefstr_to_int[params[x]]
          if @prefs[x] != pref #This slot changed
            changed = true
            availability = Availability.where(:time => Slot.get_time(daytime[0], daytime[1]), :tutor_id =>tutor.id)
            if pref == 0  #delete the existing availability for this slot
              availability.first.destroy
            else
              if availability.empty?
                tutor.availabilities << Availability.create(:time => Slot.get_time(daytime[0], daytime[1]), :preference_level=>pref)
              else
                availability.first.preference_level = pref
                availability.first.save
              end
            end
            @prefs[x] = pref
          end
        end
      end
      if changed
        redirect_to :admin_tutor_signup_slots, :notice=>"Successfully updated your tutoring preferences"
      end
    end

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
    tutors = Tutor.all
    @preferred = Hash.new
    @available = Hash.new
    for tutor in tutors
      tutor.availabilities.each do |a|
        if a.preference_level==2
          @preferred[a.time.strftime('%a%H')] ||= []; @preferred[a.time.strftime('%a%H')] << tutor
        else
          @available[a.time.strftime('%a%H')] ||= []; @available[a.time.strftime('%a%H')] << tutor
        end
      end
    end
    @assignments = Hash.new
    slots = Hash.new
    for slot in Slot.all
      @assignments[slot.to_s] = slot.tutors
      slots[slot.to_s] = slot
    end
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 13 14 15 16)
    @rows = ["Hours"] + @hours
    
    if params[:authenticity_token]  #The form was submitted
      changed=false
      @assignments.keys.each do |x|
        daytime = Slot.extract_day_time(x)
        old = @assignments[x].map {|t| t.id.to_s}
        new = params[x] || []
        for removed in old - new
          slots[x].tutors.delete Tutor.find(Integer(removed))
        end
        for added in new - old
          slots[x].tutors << Tutor.find(Integer(added))
        end
      end
    end
  end

  def settings
  end

end
