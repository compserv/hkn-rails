class Admin::TutorController < Admin::AdminController
  before_filter :authorize_tutoring, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses, :edit_schedule, :update_preferences]
  before_filter :authorize_tutoring_signup, :only=>[:signup_slots, :update_slots, :signup_courses, :add_course, :find_courses, :edit_schedule, :update_preferences]

  def expire_schedule
    #expire_action(:controller => :tutor, :action => :schedule)
  end

  def signup_slots
    prop = Property.get_or_create
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @wdays = 1..5
    @hours = prop.tutoring_start .. prop.tutoring_end
    tutor = @current_user.get_tutor

    @prefs = {}
    @wdays.each do |wday|
      @prefs[wday] = Hash.new(0)
    end
    tutor.availabilities.each {|a| @prefs[a.wday][a.hour] = a.preference_level}
    @sliders = {}
    @wdays.each do |wday|
      @sliders[wday] = Hash.new(2)
    end
    tutor.availabilities.each {|a| @sliders[a.wday][a.hour] = Availability::slider_value(a)}
    @adjacency = tutor.adjacency
  end

  def update_slots
    tutor = @current_user.get_tutor

    if params[:commit] == "Save changes"
      tutor.adjacency = params[:adjacency]
      tutor.save!

      params[:availabilities].each do |wday, hours|
        hours.each do |hour, av|
          pref = Availability::PREF[av[:preference_level].to_sym]
          slider = av[:slider].to_i
          room, strength = Availability.slider_to_room_strength(slider)
          availability = Availability.where(:wday => wday, :hour => hour, :tutor_id => tutor.id).first
          if availability.nil? and pref != 0
            Availability.create!(:wday => wday, :hour => hour, :preference_level => pref, :preferred_room => room, :room_strength => strength, :tutor => tutor)
          elsif availability and pref == 0
            availability.destroy
          elsif availability
            availability.update_attributes!(
              preference_level: pref,
              preferred_room: room,
              room_strength: strength)
          end
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

  def update_preferences
      tutor = @current_user.get_tutor
      preferences_options = {:current=>0, :completed=>1, :preferred=>2}
      course_preferences = tutor.course_preferences

      for option in preferences_options.keys
          course_ids = params[option].split.map {|c_id| c_id.to_i}

          selected = course_preferences.find_all {|c_id| course_ids.include? c_id.course_id}

          for pref in selected
              pref.level = preferences_options[option]
              pref.save
          end

      end

      flash[:notice] = "Successfully updated your tutoring preferences"
      tutor = @current_user.get_tutor
      @courses_added = tutor.courses
      render :action => :signup_courses
      #redirect_to :admin_tutor_signup_courses

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
      	    if person.in_group?("officers") and not person.committeeships.find_by_semester(Property.semester).nil?
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
    def room_preference(room_strength, preferred_room, slot_room)
      case room_strength
      when 0
        'p'
      when 1
        (preferred_room == slot_room) ? 'P' : 'p'
      else
        (preferred_room == slot_room) ? 'P' : ''
      end
    end

    def tutor_adjacency(adjacency)
      case adjacency
      when 1 then 'A' when -1 then 'a' else ''
      end
    end

    expire_schedule

    prop = Property.get_or_create
    @rooms = Slot::Room::Valid
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @wdays = Slot::Wday::Valid
    @hours = prop.tutoring_start .. prop.tutoring_end
    @only_available = params[:all_tutors].blank?

    ohpref = Struct.new(:preferred, :available, :others, :defaults)
    form_slots = {}
    @rooms.each do |room|
      form_slots[room] = {}
      @wdays.each do |wday|
        form_slots[room][wday] = {}
        @hours.each do |hour|
          form_slots[room][wday][hour] = ohpref.new([], [], [], nil)
        end
      end
    end

    # Collect availability information by room, day, and hour
    # See ApplicationModel::foreign_scope for how this works
    Availability.current.includes(:tutor => :person).each do |a|
    #Availability.current.includes(:tutor => :person).foreign_scope(:tutor, :current_scope_helper).each do |a|
      tutor = a.tutor
      wday = a.wday
      hour = a.hour

      Slot::Room::Both.each do |room|
        form_slot = form_slots[room][wday][hour]

        if form_slot == nil
          next
        end

        metadata = '(%s%s)' % [room_preference(a.room_strength, a.preferred_room, room),
                          tutor_adjacency(a.tutor.adjacency)]
        tuple = ["#{tutor.person.fullname} #{metadata}", tutor.id]

        if a.preference_level == 1
          form_slot.preferred << tuple
        else
          form_slot.available << tuple
        end
      end
    end
    # Find Others per slot
    # This is equivalent to Slot.all.each{|slot| slot.tutors = slot.tutors.current}
    Slot.includes(:tutors => :person).uniq.each do |slot|
    #Slot.includes(:tutors => :person).foreign_scope(:tutors, :current_scope_helper).uniq.each do |slot|
      wday = slot.wday
      hour = slot.hour
      form_slot = form_slots[slot.room][wday][hour]
      next unless form_slot
      form_slot.defaults = slot.tutors.map{|x| x.id}
      slot_tutor_ids = form_slot.preferred.map{|x| x[1]} + form_slot.available.map{|x| x[1]}

      slot.tutors.each do |tutor|
        if not slot_tutor_ids.include?(tutor.id)
          form_slot.others << [tutor.person.fullname, tutor.id]
          slot_tutor_ids << tutor.id
        end
      end
    end

    unless params[:all_tutors].blank?
      Slot.all.each do |slot|
        wday = slot.wday
        hour = slot.hour
        form_slot = form_slots[slot.room][wday][hour]
        next unless form_slot
        slot_tutor_ids = form_slot.preferred.map{|x| x[1]} + form_slot.available.map{|x| x[1]} + form_slot.others.map{|x| x[1]}
        Tutor.current.includes(:person).each do |tutor|
          if not slot_tutor_ids.include?(tutor.id)
            form_slot.others << [tutor.person.fullname, tutor.id]
            slot_tutor_ids << tutor.id
          end
        end
      end
    end

    # Package up availabilities into list for select form input in View
    @slot_options = {}
    @rooms.each do |room|
      @slot_options[room] = {}
      @wdays.each do |wday|
        @slot_options[room][wday] = {}
        @hours.each do |hour|
          form_slot = form_slots[room][wday][hour]
          opts = []
          opts << ['Preferred', form_slot.preferred] unless form_slot.preferred.empty?
          opts << ['Available', form_slot.available] unless form_slot.available.empty?
          opts << ['Others', form_slot.others]
          @slot_options[room][wday][hour] = {opts: opts, defaults: form_slot.defaults}
        end
      end
    end

    @stats, @happiness = compute_stats()
    [:officer, :cmember].each do |type|
      # Sorts by availability desc, name asc
      @stats[type] = @stats[type].sort_by{|tutor,stats| [-stats[0], tutor.person.fullname]}
    end
  end

  NOTHING_CHANGED = "Nothing changed in the tutoring schedule."

  def update_schedule
    errors = []
    if params[:commit] == "Save changes"
      changed = false
      Slot.all.each do |slot|
        room = slot.room.to_s
        wday = slot.wday.to_s
        hour = slot.hour.to_s
        begin
          new_assignments = params[:assignments][room][wday][hour].map{|x| x.to_i}
        # This is in case if any of the intermediate hashes is nil
        rescue NoMethodError
          next
        end
        slot.tutors.current.each do |tutor|
          unless new_assignments.include? tutor.id
            slot.tutors.delete tutor
            changed = true
          end
        end
        new_assignments.each do |tutor_id|
          unless slot.tutor_ids.include? tutor_id
            begin
              slot.tutors << Tutor.find(tutor_id)
            rescue
              errors << "Could not add #{Tutor.find(tutor_id)} to #{slot}."
            end
            changed = true
          end
        end
      end
    elsif params[:commit] == "Reset all"
      changed = true
      Slot.all.each{|slot| slot.tutors.clear}
    else
      flash[:notice] = "Invalid action."
      redirect_to :action => "edit_schedule" and return
    end

    all_tutors = !params[:only_available] || nil
    if changed
      flash[:notice] = "Tutoring schedule updated."
    elsif not params[:only_available]
      flash[:notice] = "Tutors shown for all slots."
    else
      flash[:notice] = NOTHING_CHANGED
    end
    flash[:notice] += ' ' + errors.join(' ') unless errors.empty?
    redirect_to :action => "edit_schedule", :all_tutors => all_tutors
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
    #preference_level = params[:level]
    preference_level = "current"
    @preference_options = {"current" => 0, "completed" => 1, "preferred" => 2}

    if !course
      render :json => [0, "Course not found."]
      return
    end
    #if !@preference_options.include?(preference_level)
      #render :json => [0, "Please select a preference level."]
      #return
    #end

    level = @preference_options[preference_level]
    tutor = @current_user.get_tutor
    @courses_added = tutor.courses

    if not tutor.courses.include? course
      cp = CoursePreference.new
      cp.course_id = course.id
      cp.tutor_id = tutor.id
      cp.level = level
      cp.save
      render :json => [1, course.course_abbr, cp.id]
    else
      render :json => [0, "You were already signed up for #{course}."]
    end

  end

  private

  def authorize_tutoring_signup
    authorize(['officers', 'cmembers'])
  end

  def compute_stats
    # stats[tutor] = [availabilities, 1st choice, 2nd choice, wrong assignment, adjacencies, correct office, happiness]
    stats = {officer: {}, cmember: {}}
    happiness_total = {officer: 0, cmember: 0}
    
    Tutor.all.each do |tutor|
    #Tutor.current.includes(:slots, :availabilities).each do |tutor|
      happiness = 0; first_choice = 0; second_choice = 0; adjacencies = 0; correct_office = 0; wrong_assign = 0

      tutor.slots.each do |slot|
        av = Availability.find_by_tutor_id_and_wday_and_hour(tutor.id, slot.wday, slot.hour)
        if av.nil?
          wrong_assign += 1
        else
          if av.preference_level == Availability::PREF[:preferred]
            first_choice += 1
          elsif av.preference_level == Availability::PREF[:available]
            second_choice += 1
          else
            raise "Availability with preference level of unavailable? Contradiction!?"
          end
        end

        if not av.nil?
          if slot.room == av.preferred_room or av.room_strength == 0
            correct_office += 2
          elsif av.room_strength == 1
            correct_office += 1
          end
        end

        adj_closed_list = []
        # If is a current_officer
        if tutor.adjacency != 0 and tutor.person.committeeships.current.map{|c| c.title == "officers"}.reduce(false){|x, y| x || y}
          tutor.slots.each do |other_slot|
            if not adj_closed_list.include?(other_slot)
              if slot.adjacent_to(other_slot)
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

      # This is the formula:
      happiness += 6*first_choice  - 10000*wrong_assign + adjacencies + 2*correct_office

      if tutor.person.in_group?("officers") and not tutor.person.committeeships.find_by_semester(Property.semester).nil?
        position = :officer
        stats_vector = [tutor.availabilities.count, first_choice, second_choice, wrong_assign, adjacencies, correct_office, happiness]
      elsif tutor.person.in_group?("cmembers")
        position = :cmember
        stats_vector = [tutor.availabilities.count, first_choice, second_choice, wrong_assign, correct_office, happiness]
      else
        next
        #raise "Not an officer or cmember!"
      end
      stats[position][tutor] = stats_vector
      happiness_total[position] += happiness
    end
    return stats, happiness_total
  end
end
