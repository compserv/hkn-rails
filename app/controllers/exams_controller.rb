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

  def course
    @course = Course.find_by_short_name(params[:dept_abbr], params[:full_course_number])
    klasses = Klass.where(:course_id => @course.id).order('semester DESC').reject {|klass| klass.exams.empty?}
    @exam_path = '/examfiles/' # TODO clean up

    @results = klasses.collect do |klass|
      exams = {}
      solutions = {}
      klass.exams.each do |exam|
        if exam.is_solution
          exams[exam.short_type] = exam
        else
          solutions[exam.short_type] = exam
        end
      end
      [klass.proper_semester, klass.instructors.first, exams, solutions]
    end
  end

end
