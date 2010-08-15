class Admin::TutorController < Admin::AdminController
  before_filter :authorize_tutoring, :except=>[:signup_slots, :signup_courses]
  
  def signup_slots
    tutor = @current_user.get_tutor
    @prefs = Hash.new 0
    tutor.availabilities.each {|a| @prefs[a.time.strftime('%a%H')] = a.preference_level}
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    prop = Property.get_or_create
    @hours = (prop.tutoring_start .. prop.tutoring_end).map {|x| x.to_s}
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
      else
        redirect_to :admin_tutor_signup_slots, :notice=>"You haven't changed anything in your tutoring preferences."
      end
    end
  end
  
  def signup_courses
    @course_options = Course.all.map {|x| [x.course_abbr, x.id]}
    tutor = @current_user.get_tutor
    @courses_added = tutor.courses
    if params[:authenticity_token]  #The form was submitted
      course = Course.find(params[:class].to_i)
      @debug << course
      if not tutor.courses.include? course
        tutor.courses << course
        redirect_to :admin_tutor_signup_courses, :notice=>"Successfully added #{course}"
      else
        redirect_to :admin_tutor_signup_courses, :notice=>"You were already signed up for #{course}."
      end
    end
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
          changed = true
          slots[x].tutors.delete Tutor.find(Integer(removed))
        end
        for added in new - old
          changed = true
          slots[x].tutors << Tutor.find(Integer(added))
        end
      end
      if changed
        redirect_to :admin_tutor_edit_schedule, :notice => "Tutoring schedule updated."
      else
        redirect_to :admin_tutor_edit_schedule, :notice => "Nothing changed in the tutoring schedule."
      end
    end
  end

  def settings
    prop = Property.get_or_create
    @enabled = prop.tutoring_enabled
    @message = prop.tutoring_message
    @start = prop.tutoring_start
    @end = prop.tutoring_end
    
    if params[:authenticity_token]
      prop.tutoring_enabled = params[:enabled] === "true"
      prop.tutoring_message = params[:message]
      prop.save
    end
  end

end
