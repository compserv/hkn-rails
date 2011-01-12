class Admin::CsecController < Admin::AdminController
  before_filter :authorize_csec

  def select_classes
    # If a klass has a coursesurvey, then it should be surveyed
    current_semester = Property.get_or_create.semester
    #@klasses = Klass.joins(:course).where('klasses.semester' => current_semester).order('courses.prefix, CAST(courses.course_number AS integer), courses.course_number, courses.suffix ASC')
    @klasses = Klass.current_semester
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

end
