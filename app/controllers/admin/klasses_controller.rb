class Admin::KlassesController < ApplicationController

  before_filter :authorize_csec

  before_filter :set_klass, :only => [:edit, :update]
  before_filter :set_course, :only => [:index]

  def index
    @klasses = @course.klasses
  end

  def edit
  end

  def update
    @klass.update_attributes params[:klass]

    render :edit
  end

private

  def set_course
    unless @course = Course.find_by_short_name(params[:dept],params[:num])
      redirect_to (request.referer || admin_courses_path), :notice => "No matching course found."
      return false
    end
  end

  def set_klass
    unless @klass = Klass.find(params[:id])
      redirect_back_or_default admin_klasses_path, :notice => "Invalid id #{params[:id]}"
      return false
    end
  end

end
