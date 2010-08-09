class ExamsController < ApplicationController

  def index
  end
  
  # GET /exams/browse
  # GET /exams/browse.xml
  def browse
    @ee_courses = Course.find_all_with_exams_by_department_abbr("EE")
    @cs_courses = Course.find_all_with_exams_by_department_abbr("CS")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
    end
  end
end
