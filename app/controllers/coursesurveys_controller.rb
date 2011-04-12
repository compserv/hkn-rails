class CoursesurveysController < ApplicationController
  include CoursesurveysHelper

  before_filter :show_searcharea
  before_filter :require_admin, :only => [:editrating, :updaterating, :editinstructor, :updateinstructor]

  begin # caching
    [:index, :instructors].each {|a| caches_action a, :layout => false}
    caches_action :klass, :cache_path => Proc.new {|c| klass_cache_path(c.params)}, :layout => false

    # Cache full/partial department lists
    caches_action :department, :layout => false, :cache_path => Proc.new {|c| "coursesurveys/department_#{c.params[:dept_abbr]}_#{c.params[:full_list].blank? ? 'recent' : 'full'}"}

    # Separate for admins
    #caches_action_for_admins([:instructor], :groups => %w(csec superusers))
  end
  cache_sweeper :instructor_sweeper

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

  def department
    params[:dept_abbr].downcase! if params[:dept_abbr]

    @department  = Department.find_by_nice_abbr(params[:dept_abbr])
    @prof_eff_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    @lower_div   = []
    @upper_div   = []
    @grad        = []
    @full_list   = params[:full_list].present?

    # Error checking
    return redirect_to coursesurveys_search_path("#{params[:dept_abbr]} #{params[:short_name]}") unless @department

    #Course.find(:all, :conditions => {:department_id => @department.id}, :order => 'course_number, prefix, suffix').each do |course|
    # includes(:klasses => {:instructorships => :instructor}).
    Course.where(:department_id => @department.id).includes(:instructorships).ordered.each do |course|
      next if course.invalid?

      ratings = []

      # Find only the most recent course, optionally with a lower bound on semester
      first_klass = course.klasses
      first_klass = first_klass.where(:semester => Property.make_semester(:year=>4.years.ago.year)..Property.make_semester) unless @full_list
      first_klass = first_klass.drop_while { |k| !k.survey_answers.exists? } .first
      #first_klass = first_klass.find(:first, :include => {:instructorships => :instructor} )

      # Sometimes the latest klass is really old, and not included in these results
      next unless first_klass.present?

      # Find the average, or silently fail if something is missing
      # TODO: silent is bad
      #next unless avg_rating = course.survey_answers.collect(&:mean).average #.average(:mean)
      next unless avg_rating = course.average_rating.to_f

      # Generate row
      #instructors = course.instructors.uniq[0..3]
      instructors = Instructor.find course.klasses.collect(&:instructor_ids).flatten.group_by{|i|i}.values.sort_by(&:length).reverse[0..3]
      result = { :course      => course,
                 :instructors => instructors,
                 :mean        => avg_rating,
                 :klass       => first_klass  }

      # Append course to correct list
      case course.course_number.to_i
        when   0.. 99: @lower_div
        when 100..199: @upper_div
        else           @grad
      end << result
 end

  end

  def course
    @course = Course.find_by_short_name(params[:dept_abbr], params[:short_name])

    # Try searching if no course was found
    return redirect_to coursesurveys_search_path("#{params[:dept_abbr]} #{params[:short_name]}") unless @course

    # eager-load all necessary data. wasteful course reload, but can't get around the _short_name helper.
    @course = Course.find(@course.id, :include => [:klasses => {:instructorships => :instructor}])

    effective_q  = SurveyQuestion.find_by_keyword(:prof_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)

    @results = []
    @overall = { :effectiveness  => {:max=>effective_q.max },
                 :worthwhile     => {:max=>worthwhile_q.max}
               }

    @course.klasses.each do |klass|
      next unless klass.survey_answers.exists?
      result = { :klass         => klass,
                 :instructors   => klass.instructors,
                 :effectiveness => { },
                 :worthwhile    => { }
               }

      # Some heavier computations
      [ [:effectiveness, effective_q ],
        [:worthwhile,    worthwhile_q]
      ].each do |qname, q|
        result[qname][:score] = klass.survey_answers.where(:survey_question_id => q.id).average(:mean)
        if result[qname][:score].nil? then
          logger.warn "coursesurveys#course: nil score for #{klass.to_s} question #{q.text}"
          raise
        end
      end rescue next

      @results << result
    end # @course.klasses

    [ :effectiveness, :worthwhile ].each do |qname|
      @overall[qname][:score] = @results.collect{|r|r[qname][:score]}.sum / @results.size.to_f
    end

  end

  def klass
    @klass = params_to_klass(params)

    # Error checking
    if @klass.blank?
       flash[:notice] = "No class found for #{params[:semester].gsub('_',' ')}."
       return redirect_to coursesurveys_course_path(params[:dept_abbr], params[:short_name])
    end

    @instructors, @tas = [], []

    @klass.instructorships.each do |i|
      (i.ta ? @tas : @instructors) << { :instructor => i.instructor,
                                        :answers    => (i.instructor.private ?
                                                        nil : i.survey_answers) }
    end
  end

  def _instructors(cat)
    # cat is in [:ta, :prof]
    @category = (cat==:ta ? :ta : :prof)
    @eff_q    = SurveyQuestion.find_by_keyword "#{@category.to_s}_eff".to_sym

    return redirect_to coursesurveys_path, :notice => "Invalid category" unless @category && @eff_q

    @results = []


    klasstype = (@category == :ta ? :tad_klass : :klass)
    is_ta     = (@category == :ta)

    # I know this is very convoluted, but it tries to pull as much data
    # as possible from a single query, to avoid hammering the database.
    Instructor.find(:all,
               :conditions => { :id =>
                     Instructorship.select(:instructor_id).
                                    where(:id =>
                                           SurveyAnswer.select(:instructorship_id).
                                                        where(:survey_question_id => @eff_q.id).
                                                        collect(&:instructorship_id),
                                           :ta => is_ta
                                          ).
                                    collect(&:instructor_id)
                    },
               :include => {:instructorships => {:klass => :course}},
               :order   => 'last_name, first_name'
               ).each do |i|
      @results << { :instructor => i,
                    :courses    => (is_ta ? i.tad_courses : i.instructed_courses),
                    :rating     => (i.private ? nil : i.survey_answers.where(:survey_question_id=>@eff_q.id).average(:mean))
                  }
    end
  end

  def instructors
    _instructors :prof
  end

  def tas
    _instructors :ta
    render 'instructors'
  end

  def instructor
    return redirect_to coursesurveys_instructors_path unless params[:name]

    @instructor =
        if params[:name].is_int? then
          # ID
          Instructor.find(params[:name])
        else
          # last,first
          (last_name, first_name) = params[:name].split(',')
          Instructor.find_by_name(first_name, last_name)
        end

    return redirect_to coursesurveys_search_path([first_name,last_name].join(' ')) unless @instructor
 
    # Don't do any heavy computation if cache exists
    return if fragment_exist? instructor_cache_path(@instructor)


    #-- Individual klasses --#

    @results = { :klasses     => [],
                 :tad_klasses => []  }
    @totals  = { :undergrad   => {},
                 :grad        => {}  }

    @can_edit = @current_user && authorize_coursesurveys
 
    prof_eff_q   = SurveyQuestion.find_by_keyword(:prof_eff)
    ta_eff_q     = SurveyQuestion.find_by_keyword(:ta_eff)
    worthwhile_q = SurveyQuestion.find_by_keyword(:worthwhile)

    # Build results of
    #   [ klass, my effectiveness answer, my worthwhile answer, [other instructors] ]
    # and totals
    #
    @instructor.instructorships.each do |i|
      results = @results[i.ta ? :tad_klasses : :klasses]   # BUCKET SORT YEAHHHHHH
      eff_q   = (i.ta ? ta_eff_q : prof_eff_q)
      result  = [i.klass,
                 i.survey_answers.find_by_survey_question_id(eff_q.id),
                 i.survey_answers.find_by_survey_question_id(worthwhile_q.id),
                 i.klass.send(i.ta ? :tas : :instructors).order(:last_name) - [@instructor]
                ]
      #next unless result.all?
      results << result

      t = (@totals[i.course.classification][i.course] ||= {:eff=>[], :ww=>[]})
      t[:eff]     <<  result[1].mean
      t[:ww]      <<  (result[2] ? result[2].mean : nil)
      t[:eff_max] ||= result[1].survey_question.max
      t[:ww_max ] ||= (result[2] ? result[2].survey_question.max : nil)
    end

    @totals.values.collect(&:values).flatten.each {|t| t[:ww].compact!}

    # Sort results by descending (semester, course)
    # TODO: change this to use sort_by! when we upgrade to ruby 1.9
    @results[:klasses].sort! {|a,b| b.first.course.to_s <=> a.first.course.to_s}
    @results[:klasses].sort! {|a,b| b.first.course.course_number <=> a.first.course.course_number}
    @results[:klasses].sort! {|a,b| b.first.semester <=> a.first.semester}
  end #instructor

  def editinstructor
    @instructor = Instructor.find_by_id(params[:id].to_i)
    if @instructor.nil?
      redirect_back_or_default coursesurveys_path, :notice => "Error: Couldn't find instructor with id #{params[:id]}."
    end
  end

  def updateinstructor
    @instructor = Instructor.find(params[:id].to_i)
    return redirect_back_or_default coursesurveys_path, :notice => "Error: Couldn't find instructor with id #{params[:id]}." unless @instructor

    return redirect_to coursesurveys_edit_instructor_path(@instructor), :notice => "There was a problem updating the entry for #{@instructor.full_name}: #{@instructor.errors.inspect}" unless @instructor.update_attributes(params[:instructor])

    (@instructor.klasses+@instructor.tad_klasses).each do |k|
      expire_action klass_cache_path k
    end
    return redirect_to surveys_instructor_path(@instructor), :notice => "Successfully updated #{@instructor.full_name}."
  end

  def rating
    @answer = SurveyAnswer.find(params[:id])
    return redirect_to coursesurveys_path, :notice => "Error: Couldn't find that rating." unless @answer
    @klass  = @answer.klass
    @course = @klass.course
    @instructor = @answer.instructor
    @results = []
    @frequencies = ActiveSupport::JSON.decode(@answer.frequencies)
    @total_responses = @frequencies.values.reduce{|x,y| x.to_i+y.to_i}
    @mode = @frequencies.values.max # TODO: i think this is wrong and always returns the highest score...
    # Someone who understands statistics, please make sure the following line is correct
    @conf_intrvl = @total_responses > 0 ? 1.96*@answer.deviation/Math.sqrt(@total_responses) : 0
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

      str = "%#{params[:q]}%"
      [:courses, :instructors].each do |k|
        @results[k] = FakeSearch.new
      end

      @results[:courses].results = Course.find(:all, :conditions => ['description LIKE ? OR name LIKE ? OR (prefix||course_number||suffix) LIKE ?', str, str, str])
      @results[:instructors].results = Instructor.find(:all, :select=>[:id,:first_name,:last_name,:private,:title], :conditions => ["(first_name||' '||last_name) LIKE ?", str])

      flash[:notice] = "Solr isn't started, so your results are probably lacking." if RAILS_ENV.eql?('development')
    end

    # redirect if only one result
    redirect_to surveys_instructor_path(@results[:instructors].results.first) if @results[:instructors].results.length == 1 && @results[:courses].results.empty?
    redirect_to surveys_course_path(@results[:courses].results.first) if @results[:courses].results.length == 1 && @results[:instructors].results.empty?

  end # search

  def show_searcharea
    @show_searcharea = true
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
    return nil unless @course = Course.find_by_short_name(parms[:dept_abbr], parms[:short_name])
    return nil unless sem = Klass.semester_code_from_s( parms[:semester] )

    @klass = Klass.where(:semester => sem, :course_id => @course.id)
    @klass = @klass.where(:section => params[:section].to_i) if params[:section].present? && params[:section].is_int?
    return @klass = @klass.order('section ASC').limit(1).first
  end

end
