class ResumesController < ApplicationController
  
  before_filter :authorize_indrel, :only => [:index, :resume_books]
  
  def new
    @resume = Resume.new
  end
  
  def create
    resume_file = params[:resume][:file]
    resume_constructor_args = params[:resume]
    # strftime doesn't have milliseconds in ruby 1.8.7
    # So it will just put in an "L" in resume names for now
    # and when(?) we upgrade to 1.9+ it will start writing
    # times with milliseconds
    time_string = Time.new.utc.strftime("%Y%m%d%H%M%S%L")
    if not Dir.entries("private/").include?("resumes")
      Dir.mkdir("private/resumes")
    end
    file_name = "private/resumes/#{time_string}_"+
                "#{@current_user.last_name}_" +
                "#{@current_user.first_name}.pdf"
    f = File.open(file_name, "wb")
    resume_constructor_args[:file] = file_name
    @resume = @current_user.resumes.new(resume_constructor_args)
    if @resume.save and not f.nil?
      f.write(resume_file.read)
      flash[:notice] = "Resume Uploaded"
      redirect_to account_settings_path
      # Delete all older resuems:
      old_resumes = @current_user.resumes[(1..-1)] # All but most recent res.
      old_resumes.each { |resume| @current_user.resumes.destroy(resume.id) }
    else
      render :action => "new"
    end
    if not f.nil?
      f.close
    end

    
  end
  
  def index
    @resumes = Resume.find(:all)
  end

  # Shows resume (PDF, not model data) after authorization
  def download
    @resume = Resume.find(params[:id])
    if @current_user and ( (@current_user == @resume.person) or (@current_user.in_groups?(['superusers', 'indrel'])) )
      send_file @resume.file, :type => 'application/pdf', :x_sendfile => true
    else
      redirect_to :root, :notice => "Insufficient privileges to access this page."
    end
  end
  
  private

end
