class Admin::KlassesController < ApplicationController

  before_filter :authorize_csec

  before_filter :set_klass, only: [:edit, :update]
  before_filter :set_course, only: [:index]

  def index
    @klasses = @course.klasses
  end

  def edit
  end

  def update
    @klass.update_attributes klass_params

    render :edit
  end

private

  def set_course
    unless @course = Course.lookup_by_short_name(params[:dept],params[:num])
      redirect_to (request.referer || admin_courses_path), notice: "No matching course found."
      return false
    end
  end

  def set_klass
    unless @klass = Klass.find(params[:id])
      redirect_back_or_default admin_klasses_path, notice: "Invalid id #{params[:id]}"
      return false
    end
  end

  def klass_params
    params.require(:klass).permit(
      :location,
      :time,
      :section,
      :num_students,
      :notes
    )
  end


end
