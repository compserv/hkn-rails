class CoursesurveysController < ApplicationController
  # Note: We should change all the database queries to be more Rails 3.0-like.
  def index
  end

  def department
    @department = Department.find_by_nice_abbr(params[:dept_abbr])
    @lower_div = []
    @upper_div = []
    @grad      = []
    @prof_eff_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    current_semester = (Time.now.year*10 + (Time.now.month/3)).to_s
    start_semester   = (4.years.ago.year*10 + (4.years.ago.month/3)).to_s

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

    Course.where(:department_id => @department.id).each do |course|
      instructors = []
      ratings = []
      if params[:full_list].blank?
        klasses = course.klasses.where({ :semester => start_semester.to_s..current_semester.to_s }).order(:semester)
      else
        klasses = course.klasses.order(:semester)
      end
      klasses.each do |klass|
        SurveyAnswer.find(:all, :conditions => { :klass_id => klass.id, :survey_question_id => @prof_eff_q.id }).each do |answer|
          instructors << answer.instructor_id
          ratings << answer.mean
        end
      end

      instructors = instructors.uniq[0..3]

      unless ratings.empty?
        count = ratings.size
        rating = ratings.reduce{|x,y|x+y}/count
        tuple = [course, instructors, rating, klasses.first]
        if course.course_number.to_i < 100
          @lower_div << tuple
        elsif course.course_number.to_i < 200
          @upper_div << tuple
        else
          @grad << tuple
        end
      end
    end

  end

  def course
    @course = Course.find_by_short_name(params[:dept_abbr], params[:short_name])
    effective_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)
    @effective_max  = effective_q.max.to_f
    @worthwhile_max = worthwhile_q.max.to_f

    if @course.blank?
      @errors = "Couldn't find #{params[:dept_abbr]} #{params[:short_name]}"
      render :text => "Could not find #{params[:dept_abbr]} #{params[:short_name]}"
    else
      @latest_klass = @course.klasses.find(:first, {:order => "created_at DESC"})
      @instructors = @latest_klass.instructors unless @latest_klass.nil?
      @results = []
      effective_sum = 0.0
      worthwhile_sum = 0.0
      @course.klasses.each do |klass|
        klass.instructors.each do |instructor|
          prof_eff = SurveyAnswer.find(:first, :conditions => {
            :instructor_id => instructor.id,
            :klass_id => klass.id,
            :survey_question_id => effective_q.id} )
          worthwhileness = SurveyAnswer.find(:first, :conditions => {
            :instructor_id => instructor.id,
            :klass_id => klass.id,
            :survey_question_id => worthwhile_q.id} )
          @results << [
            klass, 
            instructor, 
            prof_eff,
            worthwhileness,
          ]
          effective_sum  += prof_eff.mean
          worthwhile_sum += worthwhileness.mean
        end
      end

      unless @course.klasses.blank?
        @total_effectiveness  = effective_sum/@results.size
        @total_worthwhileness = worthwhile_sum/@results.size
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
    @klass = Klass.find(:first, :conditions => { :course_id => @course.id, :semester => semester })
    if @klass.blank?
      @errors = "No class found for #{params[:dept_abbr]} #{params[:short_name]} in #{season} #{year}."
      render :text => "No class found for #{params[:dept_abbr]} #{params[:short_name]} in #{season} #{year}."
      return
    end

    @results = []
    klass_id = @klass.id
    (@klass.instructors + @klass.tas).each do |instructor|
      if instructor.private
        answers = nil
      else
        answers = SurveyAnswer.find(:all, :conditions => { :klass_id => klass_id, :instructor_id => instructor.id}, :order => '"order"')
      end
      @results << [instructor, answers]
    end
  end

  def instructor
    (last_name, first_name) = params[:name].split(',')
    @instructor = Instructor.find_by_name(first_name, last_name)
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

      unless effectiveness.blank? or worthwhileness.blank?
        @instructed_klasses << [
          klass, 
          @instructor, 
          effectiveness,
          worthwhileness,
        ]

        if klass.course.course_number.to_i < 200 
          totals = @undergrad_totals
        else
          totals = @grad_totals
        end

        if totals.has_key? klass.course
          totals[klass.course] << [effectiveness.mean, worthwhileness.mean]
        else
          totals[klass.course] = [[effectiveness.mean, worthwhileness.mean]]
        end
      end
    end

    # Aggregate totals
    @undergrad_totals.keys.each do |course|
      scores = @undergrad_totals[course]
      count = scores.size
      total = scores.reduce{|tuple0, tuple1| [tuple0[0] + tuple1[0], tuple0[1] + tuple1[1]]}
      @undergrad_totals[course] = total.map{|score| score/count}.push count
    end
    @undergrad_total = @undergrad_totals.keys.reduce([0, 0, 0]) do |sum, new| 
      (sum_eff, sum_wth, sum_count) = sum
      (new_eff, new_wth, new_count) = @undergrad_totals[new]
      [sum_eff + new_eff*new_count, sum_wth + new_wth*new_count, sum_count+new_count]
    end
    (eff, wth, count) = @undergrad_total
    @undergrad_total = [eff/count, wth/count, count] unless count == 0

    unless @grad_totals.empty?
      @grad_totals.keys.each do |course|
        scores = @grad_totals[course]
        count = scores.size
        total = scores.reduce{|tuple0, tuple1| [tuple0[0] + tuple1[0], tuple0[1] + tuple1[1]]}
        @grad_totals[course] = total.map{|score| score/count}.push count
      end
      @grad_total = @grad_totals.keys.reduce([0, 0, 0]) do |sum, new| 
        (sum_eff, sum_wth, sum_count) = sum
        (new_eff, new_wth, new_count) = @grad_totals[new]
        [sum_eff + new_eff*new_count, sum_wth + new_wth*new_count, sum_count+new_count]
      end
      (eff, wth, count) = @grad_total
      @grad_total = [eff/count, wth/count, count] unless count == 0
    end

    @instructor.tad_klasses.each do |klass|
      effectiveness  = SurveyAnswer.find_by_instructor_klass(@instructor, klass, {:survey_question_id => ta_eff_q.id}).first
      unless effectiveness.blank?
        @tad_klasses << [
          klass, 
          @instructor, 
          effectiveness,
        ]
      end
    end
  end

  def rating
    @answer = SurveyAnswer.find(params[:id])
    @klass  = @answer.klass
    @course = @klass.course
    @instructor = @answer.instructor
    @results = []
    @frequencies = ActiveSupport::JSON.decode(@answer.frequencies)
    @total_responses = @frequencies.values.reduce{|x,y| x.to_i+y.to_i}
    @mode = @frequencies.values.max
    # Someone who understands statistics, please make sure the following line is correct
    @conf_intrvl = 1.96*@answer.deviation/Math.sqrt(@total_responses)
  end

  #def aggregate_totals_by_course(totals)
  #  # totals is a hash of courses to tuples of (ratings...)
  #  totals.keys.each do |course|
  #    scores = totals[course]
  #    count = scores.size
  #    total = scores.reduce{|tuple0, tuple1| tuple0.zip(tuple1).map{|x,y|x+y}}
  #    totals[course] = total.map{|score| score/count} + [count]
  #  end
  #  total = totals.keys.reduce([0, 0, 0]) do |sum, new| 
  #    (sum_eff, sum_wth, sum_count) = sum
  #    (new_eff, new_wth, new_count) = totals[new]
  #    [sum_eff + new_eff*new_count, sum_wth + new_wth*new_count, sum_count+new_count]
  #  end
  #  (eff, wth, count) = total
  #  _total = [eff/count, wth/count, count] unless count == 0
  #end
end
