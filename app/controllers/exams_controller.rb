class ExamsController < ApplicationController

  [:index, :browse, :course].each {|a| caches_action a, :layout => true}
    
  def index
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
      flash[:notice] = "Solr isn't started, so your results are probably lacking." if RAILS_ENV.eql?('development')
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

  # GET /exams/browse
  # GET /exams/browse.xml
  def browse
    @dept_courses = ['CS', 'EE'].collect do |dept_abbr|
      dept = Department.find_by_nice_abbr(dept_abbr)
      dept_name = dept.name
      #courses = Course.find_all_with_exams_by_department_id(dept.id)
      courses = Course.find(:all, :conditions => {:department_id=>dept.id}, :include => [:exams], :order => :course_number).reject {|course| course.exams.empty?}
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
