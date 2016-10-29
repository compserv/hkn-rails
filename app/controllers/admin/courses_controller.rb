class Admin::CoursesController < ApplicationController

  before_filter :authorize_csec
  before_filter :set_course, :only => [:show, :update]

  def index
    @courses = Course.order(:department_id).ordered
  end

  def show
  end

  def new
    @course = Course.new :department_id => Department.first.id
  end

  def create
    @course = Course.new(course_params)

    if process_course_params! and @course.save
      @messages << "Successfully added course."
      redirect_to admin_courses_show_path(*@course.slug)
    else
      @messages << (["Validation failed:"]+@course.errors.full_messages).join('<br/>').html_safe
      render :action => :new
    end
  end

  def update
    slug1 = @course.slug
    unless process_course_params!
      render :show
      return
    end

    if @course.save
      flash[:notice] = "Successfully updated course."
      if slug1 != @course.slug
        redirect_to admin_courses_show_path(*@course.slug)
        return
      end
    else
      flash[:notice] = "Validation error"
    end
    render :show
  end

private

  def course_params
    params.require(:course).permit(
      :department,
      :course_number,
      :name,
      :description,
      :units,
      :prereqs,
      :course_guide
    )
  end

  def set_course
    unless @course = Course.lookup_by_short_name(params[:dept],params[:num])
      redirect_to (request.referer || admin_courses_path), :notice => "No matching course found."
      return false
    end
  end

  # Save parameters from params[:course] to @course
  # @return [Boolean] whether processing was successful. Flash error is set if false.
  def process_course_params!
    @course.update_attributes course_params

    # Course number
    cn = Course.split_course_number params[:course][:full_course_number], :hash=>false
    @messages << cn.inspect
    @course.prefix, @course.course_number, @course.suffix = cn

    # Sanity check
    if @course.full_course_number.upcase == params[:course][:full_course_number].upcase
      params[:course].delete(:full_course_number)
    else
      flash[:notice] = "Failed to parse course number #{params[:course][:full_course_number].inspect} #{@course.full_course_number.inspect}"
      return false
    end

    return true
  end

end
