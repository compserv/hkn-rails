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
    ret += "TUTORING_DAYS = ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')</br>"
    ret += "TUTORING_TIMES = ('11a-12', '12-1', '1-2', '2-3', '3-4', '4-5')</br>"
    ret += "SCORE_CORRECT_OFFICE = 2</br>"
    ret += "SCORE_MISS_PENALTY = 10000</br>"
    ret += "SCORE_PREFERENCE = {1: 6, 2: 0}</br>"
    ret += "SCORE_ADJACENT = 1</br>"
    ret += "SCORE_ADJACENT_SAME_OFFICE = 2</br>"
    ret += "DEFAULT_HOURS = 2</br>"
    ret += "exceptions = {}</br>"
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
            if firstAvail
              firstAvail = false
            else
              ret += ' '
            end

            person = Person.where(avail.tutor.person_id == id).first
            ret += person.first_name + person.last_name[0..0]
            ret += avail.preference_level.to_s

            if avail.preferred_room == room
              ret += 'P'
            elsif avail.room_strength == 1
              ret += 'p'
            end
            if avail.adjacency == 2
              ret += 'A'
            elsif avail.adjacency == 1
              ret += 'a'
            end

          end #avail
        end #day
      end #hour
      ret += '"</br>'
    end #office

    render :text => ret
  end

  def edit_schedule
    tutors = Tutor.all
    @preferred = Hash.new
    @available = Hash.new
    for tutor in tutors
      tutor.availabilities.each do |a|
        if a.preference_level==1
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

    prop = Property.get_or_create
    @days = %w(Monday Tuesday Wednesday Thursday Friday)
    @hours = %w(11 12 13 14 15 16)
    @rows = ["Hours"] + @hours
#    @hours = prop.tutoring_start .. prop.tutoring_end
#    @rows = ["Hours"] + @hours.to_a
    
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
    @year = prop.semester[0..3]
    @semester = prop.semester[4..4]
    
    if params[:authenticity_token]
      prop.tutoring_enabled = params[:enabled] === "true"
      prop.tutoring_message = params[:message]
      prop.tutoring_start = params[:start]
      prop.tutoring_end = params[:end]
      prop.semester = params[:year] + params[:semester]
      prop.save
    end
  end

end
