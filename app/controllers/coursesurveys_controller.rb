class CoursesurveysController < ApplicationController
  include CoursesurveysHelper

  before_filter :show_searcharea
  
  before_filter :require_admin, :only => [:editrating, :updaterating]
  
  def require_admin
    return if @current_user.admin?
    flash[:error] = "You must be an admin to do that."
    redirect_to coursesurveys_path
  end

  def index
  end

  def department
    @department = Department.find_by_nice_abbr(params[:dept_abbr])
    @lower_div = []
    @upper_div = []
    @grad      = []
    @prof_eff_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    if params[:full_list].blank?
      current_semester = (Time.now.year*10 + (Time.now.month/3)).to_s
      start_semester   = (4.years.ago.year*10 + (4.years.ago.month/3)).to_s
    end

    #Course.find(:all, :conditions => { :department_id => @department.id }).each do |course|
    #Course.find(:all, 
    #            :select => "courses.*, s.effectiveness",
    #            :joins => "INNER JOIN (SELECT course_id, AVG(survey_answers.mean) AS effectiveness, ARRAY_AGG(survey_answers.instructor_id) AS instructors FROM klasses, survey_answers WHERE klass_id = klasses.id AND survey_question_id = #{@prof_eff_q.id} GROUP BY course_id) AS s ON courses.id = s.course_id",
    #            :conditions => { :department_id => @department.id },
    #            :order => "courses.course_number, courses.suffix"
    #           ).each do |course|
    #  if course.course_number.to_i < 100
    #    @lower_div << course
    #  elsif course.course_number.to_i < 200
    #    @upper_div << course
    #  else
    #    @grad << course
    #  end
    #end

    Course.find(:all, :conditions => {:department_id => @department.id}, :order => 'course_number, prefix, suffix').each do |course|
      next if course.invalid?

      ratings = []
      sort_order = 'semester DESC, section DESC'

      find_args = {:order => sort_order}
      find_args[:conditions] = {:semester => start_semester.to_s..current_semester.to_s} if params[:full_list].blank?
      first_klass = course.klasses.find(:first, find_args) #.find(:first, :conditions => conditions, :order => sort_order)

      next if first_klass.nil?   # Sometimes the latest klass is really old, and not included in these results

      avg_rating = SurveyAnswer.average(:mean, :joins => 'INNER JOIN klasses ON klasses.id = klass_id', :conditions => ['survey_question_id = ? and klasses.course_id = ?', @prof_eff_q.id, course.id])
      
      avg_rating.nil? ? next : avg_rating = avg_rating.to_f

      instructors = course.instructors.uniq[0..3]
      tuple = [course, instructors, avg_rating, first_klass] #klasses.first]
       case course.course_number.to_i
         when   0.. 99: @lower_div
         when 100..199: @upper_div
         else           @grad
       end << tuple
 end

  end

  def course
    @course = Course.find_by_short_name(params[:dept_abbr], params[:short_name])
    @course = Course.find(@course.id, :include => [:klasses => :instructors]) unless @course.nil?  # eager-load all necessary data. wasteful course reload, but can't get around the _short_name helper.
    effective_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)
    @effective_max  = effective_q.max
    @worthwhile_max = worthwhile_q.max
    @total_effectiveness = 0
    @total_worthwhileness = 0

    if @course.blank?
      @errors = "Couldn't find #{params[:dept_abbr]} #{params[:short_name]}"
      render :text => "Could not find #{params[:dept_abbr]} #{params[:short_name]}"
    else
      sort_order = "semester DESC, section DESC"
      @results = []
      effective_sum = 0.0
      worthwhile_sum = 0.0
      @course.klasses.order(sort_order).each do |klass|
        klass.instructors.each do |instructor|
          prof_eff, worthwhileness = [effective_q, worthwhile_q].collect { |q|
            klass.survey_answers.find(:first, :conditions => {:instructor_id => instructor.id, :survey_question_id => q.id}, :select => 'mean' )
          }
         
          # TODO: sometimes prof_eff or worthwhileness is missing... like if the imported data is incomplete
          # Fail gracefully
          if prof_eff.nil? or worthwhileness.nil? then
            flash[:warning] = "Data on this page may be incomplete. We're currently in the process of adding more survey responses."
            logger.warn "incomplete data. course=#{@course.id}, klass=#{klass.id}, instructor=#{instructor.id}, prof_eff=#{prof_eff.nil? ? 'nil':prof_eff.id}, ww=#{worthwhileness.nil? ? 'nil':worthwhileness.id}"
            next
          end
            
          @results << [
            klass, 
            instructor, 
            prof_eff.mean,
            worthwhileness.mean,
          ]
          
          effective_sum  += prof_eff.mean
          worthwhile_sum += worthwhileness.mean
        end
      end

      unless @results.empty?
        @total_effectiveness  = effective_sum/@results.size.to_f
        @total_worthwhileness = worthwhile_sum/@results.size.to_f
      end
    end
  end

  def klass
    @course = Course.find_by_short_name(params[:dept_abbr], params[:short_name])
    if @course.blank?
      @errors = "Couldn't find #{params[:dept_abbr]} #{params[:short_name]}"
      render :text => "Could not find #{params[:dept_abbr]} #{params[:short_name]}"
    end
    (year,season) = params[:semester].match(/^([0-9]*)_([a-zA-Z]*)$/)[1..-1]
    season_no = case season.downcase when "spring" then "1" when "summer" then "2" when "fall" then "3" else "" end
    if year.blank? or season.blank?
      @errors = "Semester #{params[:semester]} not formatted correctly."
      render :text => "Semester #{params[:semester]} not formatted correctly."
    end
    semester = year+season_no
    conditions = { :course_id => @course.id, :semester => semester }
    conditions[:section] = params[:section].to_i unless params[:section].blank?
    @klass = Klass.find(:first, :conditions => conditions, :order => "section ASC" )
    if @klass.blank?
      @errors = "No class found for #{params[:dept_abbr]} #{params[:short_name]} in #{season} #{year}."
      render :text => "No class found for #{params[:dept_abbr]} #{params[:short_name]} in #{season} #{year}."
      return
    end

    @results = (@klass.instructors + @klass.tas).collect do |instructor|
      answers = instructor.private ? nil : @klass.survey_answers.find(:all, :conditions => {:instructor_id => instructor.id}, :order => '"order"')
      [instructor, answers]
    end
  end

  def instructors
    @category   = (params[:category] == "tas") ? "Teaching Assistants" : "Instructors"
    @eff_q       = SurveyQuestion.find_by_keyword((params[:category] == "tas") ? :ta_eff : :prof_eff)

    @results = []
    Instructor.order(:last_name).each do |instructor|
      ratings = []
      SurveyAnswer.find(:all, 
                        :conditions => { :survey_question_id => @eff_q, :instructor_id => instructor.id }
                       ).each do |answer|
        ratings << answer.mean
      end
      if params[:category] == "tas"
        courses = Course.find(:all,
                   :select => "courses.id",
                   :group =>  "courses.id",
                   :conditions => "klasses_tas.instructor_id = #{instructor.id}",
                   :joins => "INNER JOIN klasses ON klasses.course_id = courses.id INNER JOIN klasses_tas ON klasses_tas.klass_id = klasses.id"
                  )
      else
        courses = Course.find(:all,
                   :select => "courses.id",
                   :group =>  "courses.id",
                   :conditions => "instructors_klasses.instructor_id = #{instructor.id}",
                   :joins => "INNER JOIN klasses ON klasses.course_id = courses.id INNER JOIN instructors_klasses ON instructors_klasses.klass_id = klasses.id"
                  )
      end
      unless ratings.empty?
        if instructor.private
          rating = "private"
        else
          rating = 1.0/ratings.size*ratings.reduce{|x,y| x+y}
        end
        @results << [instructor, courses, rating]
      end
    end
  end

  def instructor
    (last_name, first_name) = params[:name].split(',')
    @instructor = Instructor.find_by_name(first_name, last_name)
    
    cache_key = "#{@instructor.cache_key}/controllerdata"
   
    unless (cached_values = Rails.cache.read(cache_key)).nil?
      @instructed_klasses, @tad_klasses, @undergrad_totals, @undergrad_total, @grad_totals, @grad_total = Marshal.load(cached_values)
    else # no cached data loaded
    
    
    @instructed_klasses = []
    @tad_klasses = []

    @undergrad_totals = {}
    @grad_totals = {}

    prof_eff_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)
    ta_eff_q  = SurveyQuestion.find_by_keyword(:ta_eff)

    @instructor.klasses.each do |klass|
      effectiveness  = SurveyAnswer.find_by_instructor_klass(@instructor, klass, {:survey_question_id => prof_eff_q.id}).first
      worthwhileness = SurveyAnswer.find_by_instructor_klass(@instructor, klass, {:survey_question_id => worthwhile_q.id}).first

      unless (effectiveness.blank? or worthwhileness.blank?)
        @instructed_klasses << [
          klass.id, 
          @instructor.id, 
          effectiveness.id,
          worthwhileness.id,
        ]

        if klass.course.course_number.to_i < 200 
          totals = @undergrad_totals
        else
          totals = @grad_totals
        end

        totals[klass.course.id] ||= []
        totals[klass.course.id] << [effectiveness.mean, worthwhileness.mean]
#        if totals.has_key? klass.course
#          totals[klass.course.id] << [effectiveness.mean, worthwhileness.mean]
#        else
#          totals[klass.course.id] = [[effectiveness.mean, worthwhileness.mean]]
#        end
      end
    end

    # Aggregate totals
    totals = [@undergrad_totals, @grad_totals]
    total = [0,0] # will end up as [@undergrad_total, @grad_total]
    [0,1].each do |i|
      unless totals[i].empty?
        totals[i].keys.each do |course_id|
          scores = totals[i][course_id]
          count = scores.size
          total_score = scores.reduce{|tuple0, tuple1| [tuple0[0] + tuple1[0], tuple0[1] + tuple1[1]]}
          totals[i][course_id] = total_score.map{|score| score/count}.push count
        end
        total[i] = totals[i].keys.reduce([0, 0, 0]) do |sum, new| 
          (sum_eff, sum_wth, sum_count) = sum
          (new_eff, new_wth, new_count) = totals[i][new]
          [sum_eff + new_eff*new_count, sum_wth + new_wth*new_count, sum_count+new_count]
        end
        (eff, wth, count) = total[i]
        total[i] = [eff/count, wth/count, count] unless count == 0
      end
    end
    @undergrad_total, @grad_total = total


    @instructor.tad_klasses.each do |klass_id|
      effectiveness  = SurveyAnswer.find(:first, :conditions => {:instructor_id=>@instructor.id, :klass_id=>klass_id, :survey_question_id => ta_eff_q.id})
      unless effectiveness.blank?
        @tad_klasses << [
          klass_id, 
          @instructor.id, 
          effectiveness.id,
          nil                # no worthwhileness
        ]
      end
    end
    
    Rails.cache.write(cache_key, Marshal.dump([@instructed_klasses, @tad_klasses, @undergrad_totals, @undergrad_total, @grad_totals, @grad_total]))
  end # cache

  # Unwrap from id to object, for the view
  [@instructed_klasses, @tad_klasses].each do |a|
    a.each do |k|
      k[0] =        Klass.find(k[0])
      k[1] =   Instructor.find(k[1])
      k[2] = SurveyAnswer.find(k[2])
      k[3] = SurveyAnswer.find(k[3]) unless k[3].blank?
    end
  end
  
  temp = {}
  @undergrad_totals.each do |course_id,tuple|
    temp[Course.find(course_id)] = tuple
  end
  @undergrad_totals = temp

  temp = {}
  @grad_totals.each do |course_id,tuple|
    temp[Course.find(course_id)] = tuple
  end
  @grad_totals = temp


  end #instructor

  def rating
    @answer = SurveyAnswer.find(params[:id])
    @klass  = @answer.klass
    @course = @klass.course
    @instructor = @answer.instructor
    @results = []
    @frequencies = ActiveSupport::JSON.decode(@answer.frequencies)
    @total_responses = @frequencies.values.reduce{|x,y| x.to_i+y.to_i}
    @mode = @frequencies.values.max # TODO: i think this is wrong and always returns the highest score...
    # Someone who understands statistics, please make sure the following line is correct
    @conf_intrvl = 1.96*@answer.deviation/Math.sqrt(@total_responses)
  end
  
  def editrating
    @answer = SurveyAnswer.find(params[:id])
    @frequencies = decode_frequencies(@answer.frequencies)
  end
  
  def updaterating
    a = SurveyAnswer.find(params[:id])
    if a.nil? then
        flash[:error] = "Fail. updaterating##{params[:id]}"
    else
        # Hashify
        new_frequencies = decode_frequencies(a.frequencies)
        
        # Remove any rogue values: allow only score values, N/A, and Omit       
        params[:frequencies].each_pair do |key,value|
            key = key.to_i if key.eql?(key.to_i.to_s)
            new_frequencies[key] = value.to_i if ( ["N/A", "Omit"].include?(key) or (1..a.survey_question.max).include?(key) )
        end
        
        # Update fields
        a.frequencies = ActiveSupport::JSON.encode(new_frequencies)
        a.recompute_stats!
        a.save
    end
    redirect_to coursesurveys_rating_path(params[:id])
  end

  def search
    @prof_eff_q = SurveyQuestion.find_by_keyword(:prof_eff)
    @ta_eff_q   = SurveyQuestion.find_by_keyword(:ta_eff)

    # Query
    params[:q] ||= ''

    # Department
    unless params[:dept].blank?
      @dept = Department.find_by_nice_abbr(params[:dept].upcase)
      params[:dept] = (@dept ? @dept.abbr : nil)
    end

    @results = {} # [instructor, courses, rating]

    # Search courses
    @results[:courses] = Course.search do
      with(:department_id, @dept.id) if @dept
      with(:invalid, false)
      keywords params[:q] unless params[:q].blank?
      order_by :department_id
      order_by :course_number
    end

    # Search instructors
    @results[:instructors] = Instructor.search do
      keywords params[:q] unless params[:q].blank?
    end
end

  def search_BY_SQL
    @prof_eff_q = SurveyQuestion.find_by_keyword(:prof_eff)
    @ta_eff_q   = SurveyQuestion.find_by_keyword(:ta_eff)
    @eff_q = @prof_eff_q
    query = params[:query] || ""
    query.upcase!

    # If course abbr format:
    if %w[CS EE].include? query[0..1].upcase
      (dept_abbr, prefix, number, suffix) = params[:query].match(
        /((?:CS)|(?:EE))\s*([a-zA-Z]*)([0-9]*)([a-zA-Z]*)/)[1..-1]
      dept = Department.find_by_nice_abbr(dept_abbr)
      course = Course.find(:first, :conditions => {:department_id => dept.id, :prefix => prefix, :course_number => number, :suffix => suffix})
      redirect_to :action => :course, :dept_abbr => course.dept_abbr, :short_name => course.full_course_number
    end

    # Else try finding instructor
    @results = []
    name_query = params[:query].gsub(/\*/, '%').downcase
    instructors = Instructor.find(:all, :conditions => ["(lower(last_name) LIKE ?) OR (lower(first_name) LIKE ?)", name_query, name_query]
                   )
    if instructors.size == 1
      instructor = instructors.first
      redirect_to :action => :instructor, :name => instructor.last_name+","+instructor.first_name
    end

    instructors.each do |instructor|
      ratings = []
      SurveyAnswer.find(:all, 
                        :conditions => { :survey_question_id => [@prof_eff_q,@ta_eff_q], :instructor_id => instructor.id }
                       ).each do |answer|
        ratings << answer.mean
      end
      courses = Course.find(:all,
                   :select => "courses.id",
                   :group =>  "courses.id",
                   :conditions => "klasses_tas.instructor_id = #{instructor.id}",
                   :joins => "INNER JOIN klasses ON klasses.course_id = courses.id INNER JOIN klasses_tas ON klasses_tas.klass_id = klasses.id"
                  ) + 
                  Course.find(:all,
                   :select => "courses.id",
                   :group =>  "courses.id",
                   :conditions => "instructors_klasses.instructor_id = #{instructor.id}",
                   :joins => "INNER JOIN klasses ON klasses.course_id = courses.id INNER JOIN instructors_klasses ON instructors_klasses.klass_id = klasses.id"
                  )
      unless ratings.empty?
        if instructor.private
          rating = "private"
        else
          rating = 1.0/ratings.size*ratings.reduce{|x,y| x+y}
        end
        @results << [instructor, courses, rating]
      end
    end
  end

  def show_searcharea
    @show_searcharea = true
  end

end
