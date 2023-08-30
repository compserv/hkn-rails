class CoursesurveysController < ApplicationController
  # TODO: Refactor most of these into a model
  include CoursesurveysHelper

  before_action CASClient::Frameworks::Rails::Filter, only: [:auth]
  before_filter :show_searcharea
  before_filter :require_admin, only: [:editrating, :updaterating, :editinstructor, :updateinstructor, :newinstructor, :createinstructor]
  before_filter :authorize_privileged
  before_filter :authorize_csec, only: [:merge_instructors, :merge_instructors_post, :merge, :instructor_ids]

  # TODO: Reimplement caching
  # begin # caching
    #[:index, :instructors, :tas].each {|a| caches_action a, layout: false}
#    caches_action :klass, cache_path: Proc.new {|c| klass_cache_path(c.params)}, layout: false

    # Cache full/partial department lists
    #caches_action :department, layout: false,
    #  cache_path: Proc.new {|c| "coursesurveys/department_#{c.params[:dept_abbr]}_#{c.params[:full_list].blank? ? 'recent' : 'full'}"},
    #  unless:     Proc.new {|c| c.params[:semester].present? or c.params[:year].present?}

    # Separate for admins
    #caches_action_for_admins([:instructor], groups: %w(csec superusers))
  #end
  #cache_sweeper :instructor_sweeper

  def authorize_coursesurveys
    @current_user && (@auth['csec'] || @auth['superusers'])
  end

  def require_admin
    return if authorize_coursesurveys
    flash[:error] = "You must be an admin to do that."
    redirect_to coursesurveys_path
  end

  def index
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

  def get_courses_json
    return render json: view_context.get_coursechart_json("course_survey")
  end

  def auth
    redirect_to coursesurveys_path
  end

  def department
    params[:dept_abbr].downcase! if params[:dept_abbr]

    # TODO: For EE or EECS, combine the set of EE and EECS lower divs -- TAG EE-EECS

    @department  = Department.find_by_nice_abbr(params[:dept_abbr])
    @prof_eff_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    @lower_div   = []
    @upper_div   = []
    @grad        = []
    @full_list   = params[:full_list].present?
    @semester    = Property.make_semester(year: params[:year], semester: params[:semester]) if params[:year].present? and params[:semester].present?

    # Error checking
    return redirect_to coursesurveys_search_path("#{params[:dept_abbr]} #{params[:short_name]}") unless @department

    # includes(klasses: {instructorships: :instructor}).
    Course.where(department_id: @department.id).includes(:instructorships).ordered.each do |course|
      next if course.invalid?

      ratings = []

      # Find only the most recent course, optionally with a lower bound on semester
      first_klass = course.klasses
      first_klass = first_klass.where(semester: Property.make_semester(year: 4.years.ago.year)..Property.make_semester) unless @full_list
      first_klass = first_klass.where(semester: @semester) if @semester
      first_klass = first_klass.drop_while { |k| !k.survey_answers.exists? } .first
      #first_klass = first_klass.find(:first, include: {instructorships: :instructor} )

      # Sometimes the latest klass is really old, and not included in these results
      next unless first_klass.present?

      # Find the average, or silently fail if something is missing
      # TODO: silent is bad
      #next unless avg_rating = course.survey_answers.collect(&:mean).average #.average(:mean)
      next unless avg_rating = course.average_rating(@semester).to_f

      # Generate row
      # Sort by descending instructorship count
      #                            [    only instrctrs  ]         [ histogram  ]        [  ascending    ] [up to last 4][one of each]
      instructors = course.klasses.collect(&:instructors).flatten.group_by{|i|i}.values.sort_by(&:length).reverse[0..3].collect(&:first)
      result = { course:      course,
                 instructors: instructors,
                 mean:        avg_rating,
                 klass:       first_klass  }

      # Append course to correct list
      case course.course_number.to_i
        when   0.. 99 then @lower_div
        when 100..199 then @upper_div
        else           @grad
      end << result
    end

  end

  def course
    @course = Course.lookup_by_short_name(params[:dept_abbr], params[:course_number])

    # Try searching if no course was found
    unless @course
      logger.warn "Course not found: #{params[:dept_abbr]} #{params[:course_number]}"
      return redirect_to coursesurveys_search_path("#{params[:dept_abbr]} #{params[:course_number]}")
    end

    # eager-load all necessary data. wasteful course reload, but can't get around the _short_name helper.
    @course = Course.joins({klasses: {instructorships: :instructor}}).find(@course.id)

    effective_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)

    prof_eff_array = SurveyQuestion.find_all_by_keyword(:prof_eff).ids
    ta_eff_array = SurveyQuestion.find_all_by_keyword(:ta_eff).ids
    worth_array = SurveyQuestion.find_all_by_keyword(:worthwhile).ids

    @results = []
    @overall = { effectiveness:  {max: effective_q.max },
                 worthwhile:     {max: worthwhile_q.max}
               }

    @course.klasses.each do |klass|
      next unless klass.survey_answers.exists?
      result = { klass: klass, ratings: [] }

      klass.instructors.sort{|x,y| x.last_name <=> y.last_name}.each do |instructor|
        rating = { instructor: instructor }

        catch :nil_answer do
          # Some heavier computations
          #TODO: Improve efficiency. Currently performs 5 database reads per instructorship.
          current_instructorship = Instructorship.where(klass_id: klass.id).first
          current_answers = SurveyAnswer.where(instructorship_id: current_instructorship.id)
          current_eff_array   = (current_instructorship.ta ? ta_eff_array : prof_eff_array)
          current_eff_answers = current_answers.where('survey_question_id IN (?)', current_eff_array)
          current_worth_answers = current_answers.where('survey_question_id IN (?)', worth_array)
          if current_eff_answers.nil?
            logger.warn "coursesurveys#course: nil answer array for :eff"
            throw :nil_answer
          end
          if current_worth_answers.nil?
            logger.warn "coursesurveys#course: nil answer array for :worth"
            throw :nil_answer
          end
          if current_eff_answers.first.nil?
            logger.warn "coursesurveys#course: nil answer for :eff"
            throw :nil_answer
          end
          if current_worth_answers.first.nil?
            logger.warn "coursesurveys#course: nil answer for :worth"
            throw :nil_answer
          end
          current_eff_q = SurveyQuestion.where(id: current_eff_answers.first.survey_question_id).first
          current_worth_q = SurveyQuestion.where(id: current_worth_answers.first.survey_question_id).first
          if current_eff_q.nil?
            logger.warn "coursesurveys#course: nil question for :eff"
            throw :nil_answer
          end
          if current_worth_q.nil?
            logger.warn "coursesurveys#course: nil question for :worth"
            throw :nil_answer
          end
          [ [:effectiveness, current_eff_q ],
            [:worthwhile, current_worth_q]
          ].each do |qname, q|
            answer = klass.survey_answers.where(survey_question_id: q.id, instructorships: { instructor_id: instructor.id}).first
            if answer.nil?
              logger.warn "coursesurveys#course: nil score for #{klass.to_s} question #{q.text}"
              throw :nil_answer
            else
              rating[qname] = answer.mean
            end
          end
          result[:ratings] << rating
        end
      end

      @results << result
    end # @course.klasses

    [ :effectiveness, :worthwhile ].each do |qname|
      @overall[qname][:score] = @results.collect do |result|
        result[:ratings].map { |r| r[qname] }.sum.to_f / result[:ratings].size
      end.sum / @results.size.to_f
    end
  end

  def klass
    @instructor = _get_instructor(params[:instructor])
    @klass = params_to_klass(params)
    @can_edit = @current_user && authorize_coursesurveys

    # Error checking
    if @klass.blank?
      flash[:notice] = "No class found for #{params[:semester].gsub('_',' ')}."
      return redirect_to coursesurveys_course_path(params[:dept_abbr], params[:short_name])
    end

    @instructors, @tas = [], []

    @klass.instructorships.each do |i|
      if @instructor.nil? or @instructor == i.instructor
        answers = (i.instructor.private && !@privileged ? nil : i.survey_answers)
        (i.ta ? @tas : @instructors) << { instructor: i.instructor, answers: answers }
      end

      @instructorship = i if @instructor == i.instructor
    end

    if @instructor && @instructors.empty? && @tas.empty?
      flash.now[:notice] = "No instructor named #{@instructor.full_name} found for current class and semester"
      @instructor = nil
    end
  end

  def _instructors(cat, sem)
    # cat is in [:ta, :prof]
    @category = (cat==:ta ? :ta : :prof)
    @semester = sem == nil ? "" : Property.pretty_semester(sem)
    @eff_q    = SurveyQuestion.find_by_keyword "#{@category.to_s}_eff".to_sym

    return redirect_to coursesurveys_path, notice: "Invalid category" unless @category && @eff_q

    @results = []
    if %w[ name rating ].include?(params[:sort])
      order = params[:sort]
    else
      order = "name"
    end
    params[:sort_direction] ||= 'up'

    sort_direction = case params[:sort_direction]
                     when "up" then "ASC"
                     when "down" then "DESC"
                     else "ASC"
                     end
    @search_opts = {'sort' => order, 'sort_direction' => sort_direction }.merge params

    klasstype = (@category == :ta ? :tad_klass : :klass)
    is_ta     = (@category == :ta)

    # I know this is very convoluted, but it tries to pull as much data
    # as possible from a single query, to avoid hammering the database.
    if (sem == nil)
      instructors = Instructor.where(id: Instructorship.select(:instructor_id).
                                    where(id: SurveyAnswer.select(:instructorship_id).
                                                           where(survey_question_id: @eff_q.id).
                                                           collect(&:instructorship_id),
                                           ta: is_ta
                                          ).
                                    collect(&:instructor_id)
                    )
               .includes(instructorships: {klass: :course})
               .order("last_name, first_name #{order=='name' ? sort_direction : 'ASC'}")

      instructors.each do |i|
        @results << { instructor: i,
                      courses:    (is_ta ? i.tad_courses : i.instructed_courses),
                      rating:     (i.private && !@privileged ? nil : i.survey_answers.where(survey_question_id: @eff_q.id).average(:mean))
                    }
      end
    else
      instructorships = Instructorship.where(klass_id:
                           Klass.select(:id).where(semester: sem),
                           ta: (cat == :ta))
                        .includes(:instructor, :klass)

      instructorships.each do |i|
        sq = i.survey_answers.where(survey_question_id: @eff_q.id).take
        unless sq == nil
          @results << { instructor: i.instructor,
                        courses:    [i.klass.course],
                        rating:     ( i.instructor.private && !@privileged ) ? nil : sq.mean
                      }
        end
      end
    end

    if order == "rating"
      @results = case params[:sort_direction]
               when "down" then @results.sort{|e1, e2| e2[:rating].to_f <=> e1[:rating].to_f }
               else @results.sort{|e1, e2| e1[:rating].to_f <=> e2[:rating].to_f }
               end
    end
  end

  def instructors
    _instructors(:prof, params[:semester])
  end

  def tas
    _instructors(:ta, params[:semester])
    render 'instructors'
  end

  def semesters
    @semesters = Klass.select(:semester).distinct.map { |x| x.semester }.sort.reverse
  end

  def instructor
    return redirect_to coursesurveys_instructors_path unless params[:name]

    #@instructor =
    #    if params[:name].is_int? then
    #      # ID
    #      Instructor.find(params[:name])
    #    else
    #      # last,first
    #      (last_name, first_name) = params[:name].split(',')
    #      Instructor.find_by_name(first_name, last_name)
    #    end

    params[:name] ||= ""
    @instructor = _get_instructor(params[:name])

    return redirect_to coursesurveys_search_path(params[:name].split(',').reverse.join(' ')) unless @instructor

    # Don't do any heavy computation if cache exists
    #return if fragment_exist? instructor_cache_path(@instructor)


    #-- Individual klasses --#

    @results = { klasses:     [],
                 tad_klasses: []  }
    @totals  = { klasses: { undergrad:   {},
                               grad:        {}  },
                 tad_klasses: { undergrad:   {},
                                   grad:        {}  }
               }


    @can_edit = @current_user && authorize_coursesurveys

    prof_eff_q   = SurveyQuestion.find_by_keyword(:prof_eff)
    ta_eff_q     = SurveyQuestion.find_by_keyword(:ta_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)

    prof_eff_array = SurveyQuestion.find_all_by_keyword(:prof_eff).ids
    ta_eff_array = SurveyQuestion.find_all_by_keyword(:ta_eff).ids
    worth_array = SurveyQuestion.find_all_by_keyword(:worthwhile).ids
    
    # Build results of
    #   [ klass, my effectiveness answer, my worthwhile answer, [other instructors] ]
    # and totals
    #
    
    @instructor.instructorships.each do |i|
      catch :nil_answer do
        #TODO: Improve efficiency. Currently performs 4 database reads per instructorship.
        current_answers = SurveyAnswer.where(instructorship_id: i.id)
        current_eff_array   = (i.ta ? ta_eff_array : prof_eff_array)
        current_eff_answers = current_answers.where('survey_question_id IN (?)', current_eff_array)
        current_worth_answers = current_answers.where('survey_question_id IN (?)', worth_array)
        if current_eff_answers.nil?
          logger.warn "coursesurveys#instructor: nil answer array for :eff"
          throw :nil_answer
        end
        if current_worth_answers.nil?
          logger.warn "coursesurveys#instructor: nil answer array for :worth"
          throw :nil_answer
        end
        if current_eff_answers.first.nil?
          logger.warn "coursesurveys#instructor: nil answer for :eff"
          throw :nil_answer
        end
        if current_worth_answers.first.nil?
          logger.warn "coursesurveys#instructor: nil answer for :worth"
          throw :nil_answer
        end
        current_eff_q = SurveyQuestion.where(id: current_eff_answers.first.survey_question_id).first
        current_worth_q = SurveyQuestion.where(id: current_worth_answers.first.survey_question_id).first
        if current_eff_q.nil?
          logger.warn "coursesurveys#instructor: nil question for :eff"
          throw :nil_answer
        end
        if current_worth_q.nil?
          logger.warn "coursesurveys#instructor: nil question for :worth"
          throw :nil_answer
        end

        klasstype = i.ta ? :tad_klasses : :klasses
        results = @results[klasstype]   # BUCKET SORT YEAHHHHHH
        result  = [i.klass,
                  i.survey_answers.find_by_survey_question_id(current_eff_q.id),
                  i.survey_answers.find_by_survey_question_id(current_worth_q.id),
                  i.klass.send(i.ta ? :tas : :instructors).order(:last_name) - [@instructor]
                  ]
        #next unless result.all?
        next unless result[1]
        results << result

        t = (@totals[klasstype][i.course.classification][i.course] ||= {eff: [], ww: []})
        t[:eff]     <<  result[1].mean
        t[:ww]      <<  (result[2] ? result[2].mean : nil)
        t[:eff_max] ||= result[1].survey_question.max
        t[:ww_max ] ||= (result[2] ? result[2].survey_question.max : nil)
      end
    end

    @totals.values.collect(&:values).flatten.collect(&:values).flatten.each {|t| t[:ww].compact!}

    # Sort everything
    begin
      case params[:sort]
      when 'eff'
        [ :klasses, :tad_klasses ].each do |klasstype|
          @results[klasstype].sort! {|a,b| b[1].mean <=> a[1].mean} rescue nil
        end
      when 'ww'
        [ :klasses, :tad_klasses ].each do |klasstype|
          @results[klasstype].sort! {|a,b| b[2].mean <=> a[2].mean} rescue nil
        end
      else
        # Sort results by descending (semester, course)
        # TODO: change this to use sort_by! when we upgrade to ruby 1.9
        [ :klasses, :tad_klasses ].each do |klasstype|
            @results[klasstype].sort! {|a,b| b.first.course.to_s <=> a.first.course.to_s}
            @results[klasstype].sort! {|a,b| b.first.course.course_number <=> a.first.course.course_number}
            @results[klasstype].sort! {|a,b| b.first.semester <=> a.first.semester}
        end
      end

      @results.values.collect(&:reverse!) if params[:sort_direction] == 'up'
    rescue
      raise if Rails.env == 'development'
    end

  end #instructor

  def newinstructor
    @instructor = Instructor.new
  end

  def createinstructor
    @instructor = Instructor.new(instructor_params)

    if @instructor.save
      redirect_to surveys_instructor_path(@instructor), notice: "Successfully created new instructor."
    else
      render :newinstructor, notice: "Validation failed: #{@instructor.errors.to_a.join('<br/>').html_safe}"
    end
  end

  def editinstructor
    @instructor = Instructor.find_by_id(params[:id].to_i)
    if @instructor.nil?
      redirect_back_or_default coursesurveys_path, notice: "Error: Couldn't find instructor with id #{params[:id]}."
    end
  end

  def updateinstructor
    @instructor = Instructor.find(params[:id].to_i)
    return redirect_back_or_default coursesurveys_path, notice: "Error: Couldn't find instructor with id #{params[:id]}." unless @instructor

    return redirect_to coursesurveys_edit_instructor_path(@instructor), notice: "There was a problem updating the entry for #{@instructor.full_name}: #{@instructor.errors.inspect}" unless @instructor.update_attributes(instructor_params)

    #(@instructor.klasses+@instructor.tad_klasses).each do |k|
    #  expire_action(action: klass_cache_path(k))
    #end

    return redirect_to surveys_instructor_path(@instructor), notice: "Successfully updated #{@instructor.full_name}."
  end

  def rating
    @answer = SurveyAnswer.find(params[:id])
    return redirect_to coursesurveys_path, notice: "Error: Couldn't find that rating." unless @answer
    # TODO: survey answers not deleted if instructorship link broken
    if @answer.instructor.nil?
      self.render_404
    end
    @instructor = @answer.instructor
    if @instructor.private && !@privileged
      return redirect_to(coursesurveys_path, notice: "You are not authorized to view that page.")
    end

    @klass  = @answer.klass
    @course = @klass.course
    @frequencies = @answer.frequencies ? ActiveSupport::JSON.decode(@answer.frequencies) : []
    @total_responses = @frequencies.present? ? @frequencies.values.reduce { |x,y| x.to_i + y.to_i } : @answer.num_responses
    @mode = @frequencies.values.max # TODO: i think this is wrong and always returns the highest score...
    # Someone who understands statistics, please make sure the following line is correct
    @conf_intrvl = @answer.deviation ? (@total_responses > 0 ? 1.96*@answer.deviation/Math.sqrt(@total_responses) : 0) : nil
    @can_edit = @current_user && authorize_coursesurveys
  end

  def editrating
    @answer = SurveyAnswer.find(params[:id])
    @frequencies = decode_frequencies(@answer.frequencies)
  end

  def updaterating
    a = SurveyAnswer.find(params[:id])
    if a.nil? then
        flash[:error] = "Fail. updaterating##{params[:id]}"
    else
        # Hashify
        new_frequencies = decode_frequencies(a.frequencies)

        # Remove any rogue values: allow only score values, N/A, and Omit
        params[:frequencies].each_pair do |key,value|
            key = key.to_i if key.eql?(key.to_i.to_s)
            new_frequencies[key] = value.to_i if ( ["N/A", "Omit"].include?(key) or (1..a.survey_question.max).include?(key) )
        end

        # Update fields
        a.frequencies = ActiveSupport::JSON.encode(new_frequencies)
        a.recompute_stats!
        a.save
    end
    redirect_to coursesurveys_rating_path(params[:id])
  end

  def search
    return if strip_params

    @prof_eff_q = SurveyQuestion.find_by_keyword(:prof_eff)
    @ta_eff_q   = SurveyQuestion.find_by_keyword(:ta_eff)

    # Query
    params[:q] = sanitize_query(params[:q])

    # Department
    unless params[:dept].blank?
      @dept = Department.find_by_nice_abbr(params[:dept].upcase)
      params[:dept] = (@dept ? @dept.abbr : nil)
    end

    @results = {} # [instructor, courses, rating]

    if $SUNSPOT_ENABLED
      # Search courses
      @results[:courses] = Course.search do
        with(:department_id, @dept.id) if @dept
        with(:invalid, false)

        keywords params[:q] unless params[:q].blank?

        order_by :score, :desc
        order_by(:department_id, :desc) unless @dept    # hehe put CS results on top
        order_by :course_number, :asc
      end

      # Search instructors
      @results[:instructors] = Instructor.search do
        keywords params[:q] unless params[:q].blank?
      end
    else
      # Solr isn't started, hack together some results
      logger.warn "Solr isn't started, falling back to lame search"
      if $SUNSPOT_EMAIL_ENABLED
        ErrorMailer.problem_report("Solr isn't started (The only email sent until solr reactivated)").deliver
      end

      str = "%#{params[:q]}%"
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

      [:courses, :instructors].each do |k|
        @results[k] = FakeSearch.new
      end

      query_str = 'description LIKE ? OR name LIKE ? OR CONCAT(prefix, course_number, suffix) LIKE ?'
      if dept_id > -1
        query_str = '(' + query_str + ') AND department_id = ?'
        @results[:courses].results = Course.where(query_str, str, str, str_courseNum, dept_id)
      else
        @results[:courses].results = Course.where(query_str, str, str, str_courseNum)
      end
      @results[:instructors].results = Instructor.select(:id, :first_name, :last_name, :private, :title).where("CONCAT(first_name, ' ', last_name) LIKE ?", str)

      if Rails.env.development?
        flash[:notice] = "Solr isn't started, so your results are probably lacking."
      elsif @auth['compserv']
        flash[:notice] = "Solr isn't started."
      end
    end

    # redirect if only one result
    redirect_to surveys_instructor_path(@results[:instructors].results.first) if @results[:instructors].results.length == 1 && @results[:courses].results.empty?
    redirect_to surveys_course_path(@results[:courses].results.first) if @results[:courses].results.length == 1 && @results[:instructors].results.empty?

  end # search

  def show_searcharea
    @show_searcharea = true
  end

  #######################
  #       Admin         #
  #######################

  # GET /instructor_ids
  def instructor_ids
     render json: Instructor.order('last_name, first_name').collect {|i| { label: i.full_name_r, value: i.id } }
  end

  # GET /merge
  def merge_index
  end

  # GET /merge_instructors
  def merge_instructors
    @instructors = [:id_0, :id_1].collect {|s| params[s].blank? ? nil : Instructor.find(params[s])}
  end

  # POST /merge_instructors
  def merge_instructors_post
    p = {}
    @instructors = [:id_0, :id_1].collect {|s| Instructor.find(params[s]) if params[s]}

    return redirect_to coursesurveys_merge_instructors_path(params[:id_0], params[:id_1]), notice: "Invalid IDs" unless @instructors.all?

    Instructor.column_names.collect(&:downcase).collect(&:to_sym).each do |col|
      # params[col] is 0 or 1, indicating from which instructor to take the new attribute
      p[col] = @instructors[params[col].to_i].send(col) if params[col]
    end

    @instructor = Instructor.new(p)

    begin
        Instructor.transaction do
          puts "FUCK LIFE"
          raise unless @instructor.eat(@instructors)
        end
    rescue => e
      return redirect_to coursesurveys_merge_instructors_path(@instructors[0].id, @instructors[1].id), notice: [e,@instructor.errors.inspect, @instructor].inspect
    end

    redirect_to surveys_instructor_path(@instructor), notice: "This is the new instructor."
  end


  private
  def klass_cache_path(k)
    unless k.is_a? Klass
      k = params_to_klass k
    end
    p = surveys_klass_path k
    p
  end

  def params_to_klass(parms)
    return nil unless @course = Course.lookup_by_short_name(parms[:dept_abbr], parms[:short_name])
    return nil unless sem = Klass.semester_code_from_s( parms[:semester] )

    @klass = Klass.where(semester: sem, course_id: @course.id)
    @klass = @klass.where(section: params[:section].to_i) if params[:section].present? && params[:section].is_int?
    return @klass = @klass.order('section ASC').limit(1).first
  end

  def authorize_privileged
  # Sets the value of @privileged based on the user's group membership.
  # Csec, superusers, and coursesurvey groups all override @privileged to false
    @privileged = @current_user && @current_user.groups.exists?(name: ['csec', 'coursesurveys'])
    if session[:cas_user]
      user = CalnetUser.where(uid: session[:cas_user]).first
      @privileged ||= user && user.authorized_course_surveys
    end
  end

  def _get_instructor(param)
    if param.nil?
      nil
    elsif param.is_int?
      # ID
      Instructor.find(param)
    else
      # last,first
      (last_name, first_name) = param.split(',')
      Instructor.find_by_name(first_name, last_name)
    end
  end

  def instructor_params
    params.require(:instructor).permit(
      :first_name,
      :last_name,
      :title,
      :office,
      :phone_number,
      :email,
      :home_page,
      :interests,
      :private
    )
  end

end
