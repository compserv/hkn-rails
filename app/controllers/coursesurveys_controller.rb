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
end
