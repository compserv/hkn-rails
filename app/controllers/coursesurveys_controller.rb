class CoursesurveysController < ApplicationController
  def index
  end

  def course
    @course = Course.find_by_short_name(params[:dept_abbr], params[:short_name])
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
          effectiveness  = SurveyAnswer.find_by_instructor_klass(instructor, klass, {:survey_question_id => 1}).first
          worthwhileness = SurveyAnswer.find_by_instructor_klass(instructor, klass, {:survey_question_id => 2}).first
          @results << [
            klass, 
            instructor, 
            effectiveness,
            worthwhileness,
          ]
          effective_sum  += effectiveness.mean
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

    @instructor.klasses.each do |klass|
      effectiveness  = SurveyAnswer.find_by_instructor_klass(@instructor, klass, {:survey_question_id => 1}).first
      worthwhileness = SurveyAnswer.find_by_instructor_klass(@instructor, klass, {:survey_question_id => 2}).first
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
    @undergrad_total = [eff/count, wth/count, count]

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
      @grad_total = [eff/count, wth/count, count]
    end

    @instructor.tad_klasses.each do |klass|
      effectiveness  = SurveyAnswer.find_by_instructor_klass(@instructor, klass, {:survey_question_id => 27}).first
      @tad_klasses << [
        klass, 
        @instructor, 
        effectiveness,
      ]
      effective_sum  += effectiveness.mean
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
end
