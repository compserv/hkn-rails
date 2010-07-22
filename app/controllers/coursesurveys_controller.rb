class CoursesurveysController < ApplicationController
  def index
  end

  def course
    @course = Course.find_by_course_abbr(params[:id]).first
    if @course.blank?
      @errors = "Couldn't find #{params[:id]}"
    end
    @latest_klass = @course.klasses.find(:first, {:order => "created_at DESC"})
    @instructors = @latest_klass.instructors
  end
end
