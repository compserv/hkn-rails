class Admin::TutorAdminController < ApplicationController
  before_filter {|controller| controller.send(:authorize, "tutoring")}
  def index
  end

  def signup_slots
    tutor = @current_user.get_tutor
    @prefs = Hash.new 0
    tutor.availabilities.each {|a| @prefs[a.time.strftime('%a%H')] = a.preference_level}
    @messages ||= []
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
          #@messages << x +"=>"+ params[x] + " was interpreted as "+daytime.to_s + "=>"+pref.to_s
        end
      end
      if changed
        redirect_to :admin_tutor_admin_signup_slots, :notice=>"Successfully updated your tutoring preferences"
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
    @slots = Slot.all
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 13 14 15 16)
    @rows = ["Hours"] + @hours
  end

  def settings
  end

end
