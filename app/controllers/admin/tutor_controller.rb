class Admin::TutorController < Admin::AdminController
  before_filter :authorize_tutoring, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses]
  before_filter :authorize_tutoring_signup, :only=>[:signup_slots, :update_slots, :signup_courses, :add_course, :find_courses]
  
  
  def expire_schedule
    #expire_action(:controller => :tutor, :action => :schedule)
  end
  
  def signup_slots
    tutor = @current_user.get_tutor
    @prefs = Hash.new 0
    tutor.availabilities.each {|a| @prefs[a.time.strftime('%a%H')] = a.preference_level}
    @sliders = Hash.new
    tutor.availabilities.each {|a| @sliders[a.time.strftime('%a%H')] = a.get_slider_value}
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    prop = Property.get_or_create
    @hours = (prop.tutoring_start .. prop.tutoring_end).map {|x| x.to_s}
    @rows = ["Hours"] + @hours
    @adjacency = tutor.adjacency
  end
  
  def update_slots
    tutor = @current_user.get_tutor
    @prefs = Hash.new 0
    
    #Save adjacency information
    tutor.adjacency = params[:adjacency].to_i
    tutor.save

    if params[:commit] == "Save changes"
      params.keys.each do |x|
        daytime = Slot.extract_day_time(x)
        if daytime
          pref = Availability.prefstr_to_int[params[x]]
          slider = params["slider-#{x}"].to_i
          room, strength = Availability.slider_to_room_strength(slider)
          availability = Availability.where(:time => Slot.get_time(daytime[0], daytime[1]), :tutor_id =>tutor.id).first
          if availability.nil? and pref != 0
            tutor.availabilities << Availability.create(:time => Slot.get_time(daytime[0], daytime[1]), :preference_level => pref, :preferred_room => room, :room_strength => strength)
          elsif availability and pref == 0
            availability.destroy
          elsif availability
            availability.preference_level = pref
            availability.preferred_room = room
            availability.room_strength = strength
            availability.save
          end
          @prefs[x] = pref
        end
      end
    elsif params[:commit] == "Reset all"
      tutor.availabilities.destroy_all
    end
  
      redirect_to :admin_tutor_signup_slots, :notice=>"Successfully updated your tutoring preferences"
  end
  
  def signup_courses
    @course_options = Course.all.map {|x| [x.course_abbr, x.id]}
    tutor = @current_user.get_tutor
    @courses_added = tutor.courses
  end

  def params_for_scheduler(randomSeed = 'False', maximumCost = '0', machineNum = 'False', patience = 'False')
    prop = Property.get_or_create
    ret = "#HKN Mu Chapter parameters for tutoring schedule generator<br/>#Generated for "
    ret += prop.semester
    ret += Time.now.strftime(" on %a, %m/%d/%Y at %H:%M:%S <br/>")
    ret += "#To use this data, put it into a file parameters.py in the same location as scheduler.py.<br/>"
    ret += '#See https://hkn.eecs.berkeley.edu/prot/Tutoring_Scheduler on how to run the program.<br/>'
    ret += "</br>options = {'patience': " + patience
    ret += ", 'machineNum': " + machineNum
    ret += ", 'randomSeed': " + randomSeed
    ret += ", 'maximumCost': " + maximumCost + "}<br/>"

    ret += 'CORY = "Cory"</br>SODA = "Soda"</br>'
    ret += "#The following data may be modified as needed.</br>"
    ret += "TUTORING_DAYS = ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')</br>"
    ret += "TUTORING_TIMES = ('11a-12', '12-1', '1-2', '2-3', '3-4', '4-5')</br>"
    ret += "SCORE_CORRECT_OFFICE = 2</br>"
    ret += "SCORE_MISS_PENALTY = 10000</br>"
    ret += "SCORE_PREFERENCE = {1: 6, 2: 0}</br>"
    ret += "SCORE_ADJACENT = 1</br>"
    ret += "SCORE_ADJACENT_SAME_OFFICE = 2</br>"
    ret += "DEFAULT_HOURS = 2</br>"
    ret += "#Input exceptions to the number of tutoring hours below. Ex: exceptions = {u'201DummyA':3, u'597DummyB':1}</br>"
    ret += "exceptions = {} </br>"
    ret += "defaultHours = 2</br>"
    ret += "scoring = {'adjacent_same_office': 2, 'correct_office': 2, 'adjacent': 1, 'miss_penalty': 10000, 'preference': {1: 6, 2: 0}}</br></br>"

    for room in 0..1
      if room == 0
        ret += 'coryTimes = "'
      else
        ret += 'sodaTimes = "'
      end

      firstHour = true
      for hour in 11..16
        if firstHour
          firstHour = false
        else
          ret += '\n'
        end        
                
        firstDay = true
        for wday in 1..5
          if firstDay
            firstDay = false
          else
            ret += ','
          end
                    
          slot = Slot.select{|slot| slot.room == room and slot.hour == hour and slot.wday == wday}.first
          firstAvail = true
          for avail in slot.availabilities
            person = Person.find(:first, :conditions => ["id = ?", avail.tutor.person_id])
            if person.in_group?("officers")

              if firstAvail
                firstAvail = false
              else
                ret += ' '
              end
              ret += avail.tutor.id.to_s
              ret += person.first_name + person.last_name[0..0]
              ret += avail.preference_level.to_s

              if avail.room_strength == 0
                ret += 'p'
              elsif avail.preferred_room == room
                ret += 'P'
              elsif avail.room_strength == 1
                ret += 'p'
              end
              if avail.tutor.adjacency == 1
                ret += 'A'
              elsif avail.tutor.adjacency == -1
                ret += 'a'
              end

            end #officer check
          end #avail
        end #day
      end #hour
      ret += '"</br>'
    end #office

    render :text => ret
  end

  def edit_schedule
    expire_schedule
        
    @cory_preferred = Hash.new
    @cory_available = Hash.new
    @soda_preferred = Hash.new
    @soda_available = Hash.new
    @cory_others = Hash.new
    @soda_others = Hash.new

    @assignments = Hash.new
    @slots = Hash.new

    for slot in Slot.all
      @assignments[slot.to_s] = slot.tutors
      @slots[slot.to_s] = slot
      slot_tutors = []
      time = slot.time.strftime('%a%H')

      for a in slot.availabilities
        tutor = a.tutor

        str = ' ('
        if a.room_strength == 0
          str += 'p'
        elsif a.room_strength == 1
          if a.preferred_room == slot.room
            str += 'P'
          else
            str += 'p'
          end
        elsif a.preferred_room == slot.room
          str += 'P'
        end
        if tutor.adjacency == 1
          str += 'A'
        elsif tutor.adjacency == -1
          str += 'a'
        end
        str += ')'

        if slot.room == 0 
          if a.preference_level == 1
            @cory_preferred[time] ||= []; @cory_preferred[time] << [tutor, str]
          else
            @cory_available[time] ||= []; @cory_available[time] << [tutor, str]
          end
        else
          if a.preference_level == 1
            @soda_preferred[time] ||= []; @soda_preferred[time] << [tutor, str]
          else
            @soda_available[time] ||= []; @soda_available[time] << [tutor, str]
          end
        end
        slot_tutors << tutor
      end

      for tutor in slot.tutors
        if not slot_tutors.include?(tutor)
          if slot.room == 0
            @cory_others[time] ||= []; @cory_others[time] << tutor
          else
            @soda_others[time] ||= []; @soda_others[time] << tutor
          end
          slot_tutors << tutor
        end
      end

      if params[:all_tutors]
        for tutor in Tutor.all
          if not slot_tutors.include?(tutor)
            if slot.room == 0
              @cory_others[time] ||= []; @cory_others[time] << tutor
            else
              @soda_others[time] ||= []; @soda_others[time] << tutor
            end
            slot_tutors << tutor
          end
        end
      end

    end

    prop = Property.get_or_create
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = prop.tutoring_start .. prop.tutoring_end
    @rows = ["Hours"] + @hours.to_a.map! {|x| x.to_s}

    # stats[tutor] = [availabilities, 1st choice, 2nd choice, wrong assignment, adjacencies, correct office, happiness]
    @officer_stats = Hash.new; @cmember_stats = Hash.new
    officer_happiness = 0; cmember_happiness = 0
    for tutor in Tutor.all
      happiness = 0; first_choice = 0; second_choice = 0; adjacencies = 0; correct_office = 0; wrong_assign = 0

      for slot in tutor.slots
        if slot.get_preferred_tutors.include?(tutor)
          first_choice += 1
        elsif slot.get_available_tutors.include?(tutor)
          second_choice += 1
        else
          wrong_assign += 1
        end      

        avail = tutor.availabilities.find(:all, :conditions => ["time=?", slot.time]).first
        if not avail.nil?
          if slot.room == avail.preferred_room or avail.room_strength == 0
            correct_office += 2
          elsif avail.room_strength == 1
            correct_office += 1
          end
        end

        adj_closed_list = []
        if tutor.adjacency != 0 and tutor.person.in_group?("officers")
          for other_slot in tutor.slots
            if not adj_closed_list.include?(other_slot)            
              if other_slot.wday == slot.wday and (other_slot.hour - slot.hour == 1 or other_slot.hour - slot.hour == -1)
                if tutor.adjacency == 1 or tutor.adjacency == 0
                  adjacencies += 1
                end
              else
                if tutor.adjacency == -1 or tutor.adjacency == 0
                  adjacencies += 1
                end
              end
            end
          end
        end
        adj_closed_list << slot
      end

      happiness += 6*first_choice  - 10000*wrong_assign + adjacencies + 2*correct_office
      ostats = [tutor.availabilities.count, first_choice, second_choice, wrong_assign, adjacencies, correct_office, happiness]
      cstats = [tutor.availabilities.count, first_choice, second_choice, wrong_assign, correct_office, happiness]
      if tutor.person.in_group?("officers") and not tutor.person.committeeships.find_by_semester(Property.semester).empty?
        @officer_stats[tutor] ||= []; @officer_stats[tutor] << ostats; officer_happiness += happiness
      elsif tutor.person.in_group?("cmembers")
        @cmember_stats[tutor] ||= []; @cmember_stats[tutor] << cstats; cmember_happiness += happiness
      end
    end
    @officer_stats['happiness'] ||= []; @officer_stats['happiness'] << officer_happiness
    @cmember_stats['happiness'] ||= []; @cmember_stats['happiness'] << cmember_happiness
    
    if params[:authenticity_token]  #The form was submitted

      if params[:commit] == "Save changes"
        changed = false
        @assignments.keys.each do |x|
          daytime = Slot.extract_day_time(x)
          old = @assignments[x].map {|t| t.id.to_s}
          new = params[x] || []
          for removed in old - new
            changed = true
            @slots[x].tutors.delete Tutor.find(Integer(removed))
          end
          for added in new - old
            changed = true
            @slots[x].tutors << Tutor.find(Integer(added))
          end
        end
      elsif params[:commit] == "Reset all"
        changed = true
        @assignments.keys.each do |x|
          @slots[x].tutors.delete_all
        end
      end

      if changed
        flash[:notice] = "Tutoring schedule updated."
        redirect_to :action => "edit_schedule", :all_tutors => !params[:only_available]
      elsif not params[:only_available]
        flash[:notice] = "Tutors shown for all slots."
        redirect_to :action => "edit_schedule", :all_tutors => !params[:only_available]
      else
        flash[:notice] = "Nothing changed in the tutoring schedule."
        redirect_to :action => "edit_schedule", :all_tutors => !params[:only_available]
      end
    end
  end

  def settings
    prop = Property.get_or_create
    
    if request.post?
      prop.tutoring_enabled = params[:enabled] == "true"
      prop.tutoring_message = params[:message]
      prop.tutoring_start = params[:start]
      prop.tutoring_end = params[:end]
      prop.semester = params[:year] + params[:semester]
      prop.save
    end

    # You need to set these variables after saving
    @enabled = prop.tutoring_enabled
    @message = prop.tutoring_message
    @start = prop.tutoring_start
    @end = prop.tutoring_end
    @year = prop.semester[0..3]
    @semester = prop.semester[4..4]
  end

  def find_courses
    render :json => Course.all.map {|c| {:text => c.course_abbr, :url => c.id } }
  end

  def add_course
    course = Course.find(params[:course].to_i) unless params[:course].blank?
    if (course.nil? || !course.course_abbr.eql?(params[:course_query]) ) && $SUNSPOT_ENABLED then
      results = Course.search {keywords params[:course_query]}.results
      if results.length == 1 then
        course = results.first
      else
        msg = results.empty? ? "No courses matched your query." : "Multiple courses matched your query: #{results.collect(&:course_abbr).join(', ')}<br/>Select one from the autocomplete."
        render :json => [0, msg]
        return
      end
    else
      # nothing found...
    end
    preference_level = params[:level]
    @preference_options = {"current" => 0, "completed" => 1, "preferred" => 2}
    
    if !course
      render :json => [0, "Course not found."]
      return
    end
    if !@preference_options.include?(preference_level)
      render :json => [0, "Please select a preference level."]
      return
    end

    level = @preference_options[preference_level]
    tutor = @current_user.get_tutor
    @courses_added = tutor.courses
   
    if not tutor.courses.include? course
      cp = CoursePreference.create
      cp.course_id = course.id
      cp.tutor_id = tutor.id
      cp.level = level
      cp.save
      #tutor.courses << course
      #cp = tutor.course_preferences.find_by_course_id(course.id)
      #cp.level = level
      #cp.save
      render :json => [1, course.course_abbr, cp.id]
    else
      render :json => [0, "You were already signed up for #{course}."]
    end
    
  end

  private

  def authorize_tutoring_signup
    authorize(['officers', 'cmembers'])
  end


end
