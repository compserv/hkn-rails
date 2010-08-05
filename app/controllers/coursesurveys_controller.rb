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
    @instructor = Instructor.find_by_name(params[:name].gsub(/_/, ' '))
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
    puts @grad_totals
    @undergrad_totals.keys.each do |course|
      scores = @undergrad_totals[course]
      count = scores.size
      total = scores.reduce{|tuple0, tuple1| [tuple0[0] + tuple1[0], tuple0[1] + tuple1[1]]}
      @undergrad_totals[course] = total.map{|score| score/count}
    end
    @grad_totals.keys.each do |key|
      scores = @grad_totals[key]
      count = scores.size
      total = scores.reduce{|tuple0, tuple1| [tuple0[0] + tuple1[0], tuple0[1] + tuple1[1]]}
      total.map!{|effectiveness, worthwhileness| [effectiveness/total, worthwhileness/total]}
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
  end
end
