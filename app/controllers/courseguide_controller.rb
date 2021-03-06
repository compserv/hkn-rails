require 'json'
class CourseguideController < ApplicationController

  before_filter :authorize_tutoring, only: [:edit, :update]

  def authorize_courseguides
    @current_user && (@auth['tutoring'] || @auth['superusers'])
  end

  def index
  end

  def show
    @course = Course.lookup_by_short_name(params[:dept_abbr], params[:course_number])
    @can_edit = authorize_courseguides
    return redirect_to coursesurveys_search_path("#{params[:dept_abbr]} #{params[:course_number]}") unless @course
  end

  def edit
    @course = Course.lookup_by_short_name(params[:dept_abbr], params[:course_number])
    if @course.nil?
      redirect_back_or_default coursesurveys_path, notice: "Error: No such course."
    end
  end

  def update
    @course = Course.lookup_by_short_name(params[:dept_abbr], params[:course_number])
    if @course.nil?
      return redirect_back_or_default coursesurveys_path, notice: "Error: That course does not exist."
    end

    if @course.update_attributes(courseguide_params)
      redirect_to courseguide_show_path(@course.dept_abbr, @course.full_course_number), notice: "Successfully updated the course guide for #{@course.course_name}."
    else
      redirect_to courseguide_show_path(@course.dept_abbr, @course.full_course_number), notice: "Error updating the entry: #{@course.errors.inspect}"
    end
  end

  def update_render_pos
    data = params[:data]
    data.each do |x|
      course = CourseChart.where(course_id: x[1][:id])
      if course.any?
        course[0].startX = x[1][:startX]
        course[0].startY = x[1][:startY]
        course[0].save
      end
    end
    
    return render json: "{'result':'success'}"
  end

  def get_courses_json
    return render json: view_context.get_coursechart_json("course_guide")
  end

  private
  def courseguide_params
    params.require(:course).permit(
      :course_guide,
    )
  end

end
