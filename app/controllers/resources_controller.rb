class ResourcesController < ApplicationController
  before_filter :authorize_tutoring, :only => [:create, :new]

# [:index, :department, :course].each {|a| caches_action a, :layout => false}

  # GET /exams
  # GET /exams.xml

  def new
    @resource = Resource.new
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
      redirect_to :action => :new
      return
    end

    klass = Klass.find_by_course_id_and_semester(course_id, semester)
    unless klass
      flash[:notice] = "Could not find that class.  Maybe the year or semester is wrong."
      redirect_to :action => :new
      return
    end

    exam_file = params[:file_info]
    unless exam_file
      flash[:notice] = "Please attach an exam file"
      redirect_to :action => :new
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
        flash[:notice] = "Must supply number representing which exam this                          is."
        redirect_to :action => :new
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
      redirect_to :action => :new
      return
    end

    # check to see if we have that exam already
    existing = Exam.where({ :klass_id => exam_constructor_args[:klass_id],
                            :course_id => exam_constructor_args[:course_id],
                            :exam_type => exam_constructor_args[:exam_type],
                            :number => exam_constructor_args[:number],
                            :is_solution => exam_constructor_args[:is_solution]})
    unless existing.empty?
      flash[:notice] = "An uploaded exam already exists for that input"
      redirect_to :action => :new
      return
    end

    begin
      @exam = Exam.new(exam_params)
      if File.exists? exam_path
        flash[:notice] = "An uploaded exam already exists for that input"
        redirect_to :action => :new
        return
      end

      f = File.open(exam_path, 'wb')

      if @exam.valid? and not f.nil?
        f.write(exam_file.read)
        @exam.save
        flash[:notice] = "Exam Uploaded!"
        redirect_to :action => :new
      end
    ensure
      f.close if f
    end
  end

  def resource_params
    params.permit(
      :klass_id,
      :course_id,
      :linkfilename,
      :type,
      :topic,
      :description
    )
  end

end
