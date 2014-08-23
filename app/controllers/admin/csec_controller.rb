include Process

class Admin::CsecController < Admin::AdminController
  before_filter :authorize_csec

  def upload_surveys
    # Displays form for upload course surveys
    @results = {:errors=>[], :info=>[]}
    @success = @allow_save = false
  end

  def upload_surveys_post
    # The actual file upload

    return redirect_to admin_csec_upload_surveys_path, :notice => "Please select a file to upload." unless params[:file]

##    if params[:save] then
##      Process.fork { system "rake db:backup:dump RAILS_ENV=#{Rails.env}" }
##      Process.wait
##    end

    @results    = SurveyData::Importer.import(:csv, params[:file].tempfile, params[:save], params[:ta])
    @success    = @results[:errors].empty?
    @allow_save = @success && !params[:save]
    @ta         = !!params[:ta]
    @results[:errors] << "No data was imported because of the above errors." if !@success && params[:save]
    render 'upload_surveys'

##    unless results[:errors].empty? then
##      return redirect_to admin_csec_upload_surveys_path, :notice => "There was #{results[:errors].length} #{'error'.pluralize_for results[:errors].length} parsing that file:\n#{results[:errors].join('
##')}"   # wtf. it won't take '\n'.
##    else
##      return redirect_to admin_csec_upload_surveys_path, :notice => "Successful upload and parse. Please verify the information below."
##    end
  end
  
  def select_classes
    # If a klass has a coursesurvey, then it should be surveyed
    current_semester = Property.get_or_create.semester
    #@klasses = Klass.joins(:course).where('klasses.semester' => current_semester).order('courses.prefix, CAST(courses.course_number AS integer), courses.course_number, courses.suffix ASC')
    @klasses = Klass.current_semester.ordered
  end

  def select_classes_post
    Klass.current_semester.each do |klass|
      if params.has_key?("klass#{klass.id}") and klass.coursesurvey.nil?
        # This should not fail
        Coursesurvey.create!(:klass => klass)
      elsif !params.has_key?("klass#{klass.id}") and !klass.coursesurvey.nil?
        klass.coursesurvey.delete
      end
    end
    prop = Property.get_or_create
    prop.coursesurveys_active = !params[:coursesurveys_active].blank?
    prop.save
    redirect_to(admin_csec_select_classes_path, :notice => "Updated classes to be surveyed")
  end

  def manage_classes
    @coursesurveys = Coursesurvey.current_semester
  end

  def manage_classes_post
    params.keys.reject{|x| !(x =~ /\Asurvey[0-9]*\z/)}.each do |param_id|
      id = param_id[6..-1]
      coursesurvey = Coursesurvey.find(id)
      # This should not fail
      coursesurvey.update_attributes(params[param_id])
      if !coursesurvey.valid?
        redirect_to(admin_csec_manage_classes_path, :notice => "Error happened. Your input was probably not valid.")
        return
      end
    end
    redirect_to(admin_csec_manage_classes_path, :notice => "Updated classes")
  end

  def coursesurvey_show
    @coursesurvey = Coursesurvey.find_by_id(params[:id]) rescue nil

    return redirect_to admin_csec_manage_classes_path, :notice => "Invalid coursesurvey ID" unless @coursesurvey
  end

  def coursesurvey_remove
    @coursesurvey = Coursesurvey.find_by_id(params[:coursesurvey_id]) rescue nil
    @person = Person.find_by_id(params[:person_id]) rescue nil

    return redirect_to admin_csec_manage_classes_path, :notice => "Invalid coursesurvey ID" unless @coursesurvey
    return redirect_to admin_csec_coursesurvey_path(@coursesurvey), :notice => "Invalid person ID" unless @person
    return redirect_to admin_csec_coursesurvey_path(@coursesurvey), :notice => "#{@person.full_name} is not surveying #{@coursesurvey.klass.to_s}" unless @coursesurvey.surveyors.include?(@person)

    @coursesurvey.surveyors.delete(@person)
    @coursesurvey.save

    redirect_to admin_csec_coursesurvey_path(@coursesurvey), :notice => "Removed #{@person.full_name} from #{@coursesurvey.klass.to_s} survey"
  end

  def manage_candidates
    @people = Person.current_candidates.alpha
  end
end
