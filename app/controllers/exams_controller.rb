class ExamsController < ApplicationController
  before_filter :authorize_tutoring, except: [:index, :department, :search, :course]

# [:index, :department, :course].each {|a| caches_action a, layout: false}

  # GET /exams
  # GET /exams.xml

  def destroy
    @exam = Exam.find(params.require(:id))
    course = @exam.course
    @exam.destroy
    flash[:notice] = "Exam deleted."
    redirect_to exams_course_path(course.department.abbr, course.full_course_number)
  end

  def new
    @exam = Exam.new
    @person = @current_user
  end

  def create
    puts params
    puts 'exam'
    puts params[:exam]
    puts params.class

    semester = params[:year] + params[:semester]
    course_id = params[:exam][:course_id]
    course = Course.find_by_id(params[:exam][:course_id])
    unless course
      flash[:notice] = "Not a valid course."
      redirect_to action: :new
      return
    end

    klass = Klass.find_by_course_id_and_semester(course_id, semester)
    unless klass
      flash[:notice] = "Could not find that class.  Maybe the year or semester is wrong."
      redirect_to action: :new
      return
    end

    exam_file = params[:file_info]
    unless exam_file
      flash[:notice] = "Please attach an exam file"
      redirect_to action: :new
      return
    end

    params[:exam][:klass_id] = klass.id
    params[:exam][:course_id] = params[:exam][:course_id].to_i

    # now we need to make the exam file name
    semester_mapping = { '1' => 'sp',
                         '2' => 'su',
                         '3' => 'fa' }
    exam_type_mapping = {'0' => 'q',
                         '1' => 'mt',
                         '2' => 'f'}
    abbr = course.course_abbr.downcase
    semester_year = semester_mapping[params[:semester]] + params[:year][-2..-1]
    if params[:exam][:exam_type] == '2'
      exam_num = exam_type_mapping[params[:exam][:exam_type]]
      params[:exam][:number] = nil
    else
      # the only case where we don't have a number with the exam type
      # is for finals
      if params[:exam][:number].empty? or params[:exam][:number].to_i <= 0
        flash[:notice] = "Must supply number representing which exam this is."
        redirect_to action: :new
        return
      else
        exam_num = exam_type_mapping[params[:exam][:exam_type]]+params[:exam][:number]
        params[:exam][:number] = params[:exam][:number].to_i
      end
    end

    params[:exam][:exam_type] = params[:exam][:exam_type].to_i

    file_ext = File.extname(params[:file_info].original_filename)
    if params[:exam][:is_solution] == "true"
      exam_name = "#{abbr}_#{semester_year}_#{exam_num}_sol#{file_ext}"
      params[:exam][:is_solution] = true
    else
      exam_name = "#{abbr}_#{semester_year}_#{exam_num}#{file_ext}"
      params[:exam][:is_solution] = false
    end

    params[:exam][:filename] = exam_name

    exam_constructor_args = params[:exam]

    exam_directory = 'public/examfiles/'
    if not Dir.entries('public/').include? 'examfiles'
      Dir.mkdir('public/examfiles')
    end

    exam_path = exam_directory + exam_name
    allowed_file_extensions = ['.pdf', '.txt']
    unless allowed_file_extensions.include? file_ext
      flash[:notice] = "An error occurred.  Currently supported file
                        types are #{allowed_file_extensions.join(', ')}.
                        Make sure the exam file is one of these"
      redirect_to action: :new
      return
    end

    # check to see if we have that exam already
    existing = Exam.where({ klass_id: exam_constructor_args[:klass_id],
                            course_id: exam_constructor_args[:course_id],
                            exam_type: exam_constructor_args[:exam_type],
                            number: exam_constructor_args[:number],
                            is_solution: exam_constructor_args[:is_solution]})
    unless existing.empty?
      flash[:notice] = "An exam record already exists for that input"
      redirect_to action: :new
      return
    end

    begin
      @exam = Exam.new(exam_params)
      if File.exists? exam_path
        flash[:notice] = "An uploaded exam file already exists for that input"
        redirect_to action: :new
        return
      end

      f = File.open(exam_path, 'wb')

      if @exam.valid? and not f.nil?
        f.write(exam_file.read)
        @exam.save
        flash[:notice] = "Exam Uploaded!"
        redirect_to action: :new
      end
    ensure
      f.close if f
    end
  end

  def index
    @dept_courses = ['CS', 'EE'].collect do |dept_abbr|
      Exam.get_dept_name_courses_tuples(dept_abbr)
    end

    @counts = {}
    Exam.select("klass_id, course_id, exam_type, number").
      group([:course_id, :klass_id, :number, :exam_type]).
      count(:all).each {|course, count|
        @counts[course[0]] ? @counts[course[0]] += 1 : @counts[course[0]] = 1}

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @exams }
    end
  end

  def department
    @dept_name, @courses = Exam.get_dept_name_courses_tuples(params[:dept_abbr])

    if (@dept_name.length() == 0) && ( @courses.length() == 0) then
      self.render_404
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @exams }
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
      # Solr isn't started, hack together some results and notify compserv
      logger.warn "Solr isn't started, falling back to lame search"
      if $SUNSPOT_EMAIL_ENABLED
        ErrorMailer.problem_report("Solr isn't started (The only email sent until solr reactivated)").deliver
      end

      str = "%#{query}%"
      str_courseNum = str.downcase.delete(" ")
      dept_id = -1

      eecs_term = !(str_courseNum.slice! "eecs").nil?
      if eecs_term
        eecs_depts = Department.where(abbr: "EECS")
        if eecs_depts.length > 0
          dept_id = eecs_depts.first.id
        end
      end

      cs_term = !(str_courseNum.slice! "cs").nil?
      cs_term = !(str_courseNum.slice! "compsci").nil? || cs_term
      if cs_term
        cs_depts = Department.where(abbr: "COMPSCI")
        if cs_depts.length > 0
          dept_id = cs_depts.first.id
        end
      end

      ee_term = !(str_courseNum.slice! "ee").nil?
      ee_term = !(str_courseNum.slice! "eleng").nil? || ee_term
      if ee_term
        ee_depts = Department.where(abbr: "EL ENG")
        if ee_depts.length > 0
          dept_id = ee_depts.first.id
        end
      end

      str_courseNum = str_courseNum.upcase

      query_str = 'description LIKE ? OR name LIKE ? OR CONCAT(prefix, course_number, suffix) LIKE ?'
      if dept_id > -1
        query_str = '(' + query_str + ') AND department_id = ?'
        @results[:courses] = Course.where(query_str, str, str, str_courseNum, dept_id)
      else
        @results[:courses] = Course.where(query_str, str, str, str_courseNum)
      end

      if Rails.env.development?
        flash[:notice] = "Solr isn't started, so your results are probably lacking."
      elsif @auth['compserv']
        flash[:notice] = "Solr isn't started."
      end
    end

    # if very likely have a single match, just go to it
    if @results[:courses].length == 1 then
      c = @results[:courses].first
      redirect_to exams_course_path(c.dept_abbr, c.full_course_number)
      return
    end

    # multiple results
    respond_to do |format|
      format.html { render action: :search }
      format.xml { render xml: @results }
    end
  end

  def course
    dept_abbr = params[:dept_abbr].upcase
    full_course_num = params[:full_course_number].upcase
    @course = Course.lookup_by_short_name(dept_abbr, full_course_num)
    return redirect_to exams_search_path([dept_abbr,full_course_num].compact.join(' ')) unless @course
    klasses = Klass.where(course_id: @course.id).order('semester DESC').reject {|klass| klass.exams.empty?}
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

  def exam_params
    params.require(:exam).permit(
      :klass_id,
      :course_id,
      :filename,
      :exam_type,
      :number,
      :is_solution
    )
  end

end
