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
      @instructors = @latest_klass.instructors unless @lastest_klass.nil?
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
    @results = []
  end
end
