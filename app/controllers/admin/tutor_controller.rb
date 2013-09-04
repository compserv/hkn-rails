require 'json'

class Admin::TutorController < Admin::AdminController
  before_filter :authorize_tutoring, :except=>[:signup_slots, :signup_courses, :update_slots, :add_course, :find_courses, :edit_schedule, :update_preferences]
  before_filter :authorize_tutoring_signup, :only=>[:signup_slots, :update_slots, :signup_courses, :add_course, :find_courses, :edit_schedule, :update_preferences]
  
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
      
      availability_count = 0
      params[:availabilities].each do |wday, hours|
        hours.each do |hour, av|
          pref = Availability::PREF[av[:preference_level].to_sym]
          if pref != 0
            availability_count += 1
          end
        end
      end
      
      if availability_count < 5 # Force at least 5 time slot availabilities per tutor
        redirect_to :admin_tutor_signup_slots, 
          :notice=>"Please provide at least 5 time slot availabilities."
        return
      end
    
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

  @@OFFICES = [:Cory, :Soda]
  @@DAYS = [:Monday, :Tuesday, :Wednesday, :Thursday, :Friday]
  @@HOURS = (11..16).to_a
  
  def gen_course_list 
    # Create ["cs61a", "cs61b", ... ] 
    Course.joins(:course_preferences).
      where(:course_preferences => {:tutor_id=>Tutor.current}).
      ordered.uniq.collect(&:course_abbr)
  end 
   
  def gen_tutor_course_prefs 
    course_array = gen_course_list 
     
    # Create {"cs61a" : 0, "cs61b" : 1, ...} 
    course_indices = {} 
    course_array.each_with_index do |course, index|
      course_indices[course] = index
    end 
         
    # Create list of "prefs": [1, 0, 1] for each tutor 
    # -1: Not taken, 0: Currently taking, 1: Has taken, 2: Preferred 
    tutor_prefs = {} 
    Tutor.current.each do |tutor|
      course_prefs = Array.new(course_array.length, -1) 
      tutor.course_preferences.each do |course_pref|
        course_prefs[course_indices[course_pref.course.course_abbr]] = course_pref.level
      end
      tutor_prefs[tutor.person.id] = course_prefs
    end

    tutor_prefs
  end

  def slot_id(day, hour, office)
    num_hours = @@HOURS.length
    num_days = @@DAYS.length
    (num_hours*(day - 1)) + (hour - @@HOURS[0]) + (office * num_hours * num_days) 
  end
   
  def adj_slots(slot) 
    this_slot_id = slot_id(slot.wday, slot.hour, slot.room)
    hour = slot.hour
    
    if hour == @@HOURS[0]
      [this_slot_id + 1]
    elsif hour == @@HOURS[-1]
      [this_slot_id - 1]
    else
      [this_slot_id - 1, this_slot_id + 1] 
    end 
  end
   
  def get_tutor_slot_prefs(tutor)
    num_times = @@HOURS.length * @@DAYS.length
    num_slots = @@HOURS.length * @@DAYS.length * @@OFFICES.length
    
    time_prefs = Array.new(num_slots, 0) 
    office_prefs = Array.new(num_slots, 0) #Cory >> -2, -1, 0, 1, 2 >> Soda 
    tutor.availabilities.where(:semester => Property.semester).each do |slot|
      this_slot_id = slot_id(slot.wday, slot.hour, 'Cory' == slot.preferred_room ? 0 : 1) 
         
      office_prefs[this_slot_id] = 1 * slot.room_strength 
      # If cory or no pref, set pref to negative
      # (Because EE is currently less popular than CS)
      if slot.preferred_room == 0
        office_prefs[this_slot_id] *= -1
      end 
      
      office_prefs[(this_slot_id + num_times) % num_slots] = -1 * office_prefs[this_slot_id]
      time_prefs[this_slot_id] = slot.preference_level # Either 1 or 2... I think...
      time_prefs[(this_slot_id + num_times) % num_slots] = time_prefs[this_slot_id]
    end
    return time_prefs, office_prefs
  end 
  
  def num_slot_assignments(tutor)
    if tutor.person.current_officer?
      2
    elsif tutor.person.current_cmember?
      1
    else # For former officers and cmembers
      0
    end
  end

  def params_for_scheduler(randomSeed = 'False', maximumCost = '0', machineNum = 'False', patience = 'False') 
    # Room 0 = Cory; Room 1 = Soda 
    # Adjacency -1 = Does not want adjacent, 0 = Don't care, 1 = Wants adjacent 
     
    # Course names 
    course_list = gen_course_list
    
    # Course prefs
    cory_course_pref = course_list.map{|course| (course[0..1] == 'EE' or course[0..3] == 'PHYS') ? 1 : 0} 
    soda_course_pref = course_list.map{|course| (course[0..1] == 'CS' or course[0..3] == 'MATH') ? 1 : 0}

    # Tutors 
    all_tutors = []
    tutor_course_prefs = gen_tutor_course_prefs
    Tutor.current.uniq.each do |tutor|
      tutor_slot_prefs = get_tutor_slot_prefs(tutor) 
      
      tutor_obj = {
        'tid' => tutor.person.id, 
        'name' => tutor.person.fullname,
        'timeSlots' => tutor_slot_prefs[0],
        'officePrefs' => tutor_slot_prefs[1],
        'courses' => tutor_course_prefs[tutor.person.id],
        'adjacentPref' => tutor.adjacency,
        'numAssignments' => num_slot_assignments(tutor)
      }
      
      all_tutors.push(tutor_obj)
    end
     
    # Timeslots 
    all_slots = []
    Slot.all.each do |slot|
      office_course_prefs = (slot.room == 0 ? cory_course_pref : soda_course_pref) 
      this_slot_id = slot_id(slot.wday, slot.hour, slot.room)
      
      slot_obj = {
        'sid' => this_slot_id,
        'name' => 'InternalSlot' + slot.id.to_s,
        'adjacentSlotIDs' => adj_slots(slot),
        'courses' => office_course_prefs,
        'day' => @@DAYS[slot.wday-1],
        'hour' => slot.hour,
        'office' => @@OFFICES[slot.room]
      }
      
      all_slots.push(slot_obj)
    end

    # Generate JSON output
    ret = {
      'courseName' => course_list,
      'tutors' => all_tutors,
      'slots' => all_slots
    }
    
    render :text => JSON.pretty_generate(ret)
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
          if tutor.person.committeeships.find_by_semester(Property.semester).nil?
            next
          end
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
        #slot.tutors.all.each do |tutor|
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
    
    Tutor.current.includes(:slots, :availabilities).each do |tutor|
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
      happiness += 6*first_choice - 10000*wrong_assign + adjacencies + 2*correct_office

      if tutor.person.current_officer?
        position = :officer
        stats_vector = [tutor.availabilities.count, first_choice, second_choice, wrong_assign, adjacencies, correct_office, happiness]
      elsif tutor.person.current_cmember?
        position = :cmember
        stats_vector = [tutor.availabilities.count, first_choice, second_choice, wrong_assign, correct_office, happiness]
      else
        raise "Not an officer or cmember!"
      end
      stats[position][tutor] = stats_vector
      happiness_total[position] += happiness
    end
    return stats, happiness_total
  end
end
