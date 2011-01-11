class ExamsController < ApplicationController

  def index
  end

  # GET /exams/browse
  # GET /exams/browse.xml
  def browse
    @dept_courses = ['CS', 'EE'].collect do |dept_abbr|
      dept_name = Department.find_by_nice_abbr(dept_abbr).name
      courses = Course.find_all_with_exams_by_department_abbr(dept_abbr)
      [dept_name, courses]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
    end
  end
end
