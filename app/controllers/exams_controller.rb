class ExamsController < ApplicationController

# [:index, :department, :course].each {|a| caches_action a, :layout => false}

  # GET /exams
  # GET /exams.xml
  def index
    @dept_courses = ['CS', 'EE'].collect do |dept_abbr|
      Exam.get_dept_name_courses_tuples(dept_abbr)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
    end
  end

  def department
    @dept_name, @courses = Exam.get_dept_name_courses_tuples(params[:dept_abbr])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @exams }
    end
  end

  def search
    return if strip_params
    query = @query = sanitize_query(params[:q])

    @results = {}

    if $SUNSPOT_ENABLED
      @results[:courses] = Course.search do
        with(:invalid, false)
        keywords query   # this needs to be a local var, not an instance var, b/c of scoping issues
        order_by :score, :desc
        order_by :department_id
      end.results
    else
      # Solr isn't started, hack together some results
      logger.warn "Solr isn't started, falling back to lame search"

      str = "%#{@query}%"

      @results[:courses] = Course.find(:all, :conditions => ['description LIKE ? OR name LIKE ? OR (prefix||course_number||suffix) LIKE ?', str, str, str])
      flash[:notice] = "Solr isn't started, so your results are probably lacking." if Rails.env.development?
     end

    # if very likely have a single match, just go to it
    if @results[:courses].length == 1 then
      c = @results[:courses].first
      redirect_to exams_course_path(c.dept_abbr, c.full_course_number)
      return
    end

    # multiple results
    respond_to do |format|
      format.html { render :action => :search }
      format.xml { render :xml => @results }
    end
  end

  def course
    dept_abbr = params[:dept_abbr].upcase
    full_course_num = params[:full_course_number].upcase
    @course = Course.find_by_short_name(dept_abbr, full_course_num)
    return redirect_to exams_search_path([dept_abbr,full_course_num].compact.join(' ')) unless @course
    klasses = Klass.where(:course_id => @course.id).order('semester DESC').reject {|klass| klass.exams.empty?}
    @exam_path = '/examfiles/' # TODO clean up

    @results = klasses.collect do |klass|
      exams = {}
      solutions = {}
      klass.exams.each do |exam|
        if not exam.is_solution
          exams[exam.short_type] = exam
        else
          solutions[exam.short_type] = exam
        end
      end
      [klass.proper_semester, klass.instructors.first, exams, solutions]
    end
  end

end
