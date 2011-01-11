class Admin::TutorController < Admin::AdminController
  before_filter :authorize_tutoring, :except=>[:signup_slots, :signup_courses]
  
  def signup_slots
    tutor = @current_user.get_tutor
    @prefs = Hash.new 0
    tutor.availabilities.each {|a| @prefs[a.time.utc.strftime('%a%H')] = a.preference_level}
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
          @preferred[a.time.utc.strftime('%a%H')] ||= []; @preferred[a.time.utc.strftime('%a%H')] << tutor
        else
          @available[a.time.utc.strftime('%a%H')] ||= []; @available[a.time.utc.strftime('%a%H')] << tutor
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

  def find_courses
    render :json => Course.all.map {|c| c.course_abbr }
  end

  def add_course
    course_name = params[:course]
    preference_level = params[:level]
    @course_options = Hash[Course.all.map {|x| [x.course_abbr, x.id]}]
    @preference_options = {"current" => 0, "completed" => 1, "preferred" => 2}
    if !@course_options.include?(course_name)
      render :text => "Course not found."
      return
    end
    if !@preference_options.include?(preference_level)
      render :text => "Please select a preference level."
      return
    end
    course_id = @course_options[course_name]
    level = @preference_options[preference_level]
    tutor = @current_user.get_tutor
    @courses_added = tutor.courses
    if params[:authenticity_token]  #The form was submitted
      course = Course.find(course_id)
      @debug << course
      if not tutor.courses.include? course
        cp = CoursePreference.create
        cp.course_id = course_id
        cp.tutor_id = tutor.id
        cp.level = level
        cp.save
        #tutor.courses << course
        #cp = tutor.course_preferences.find_by_course_id(course_id)
        #cp.level = level
        #cp.save
        render :text => cp.id.to_s()
      else
        render :text => "You were already signed up for #{course}."
      end
    end
  end

end
