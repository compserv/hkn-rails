class ResumesController < ApplicationController
  
  before_filter :authorize_indrel, :only => [:index, :resume_books, :upload_for]
  
  def new
    @resume = Resume.new
    @person = @current_user
  end

  def upload_for
    @resume = Resume.new
    @person = Person.find(params[:id])
  end
  
  def create
    if params[:resume][:person].to_i != @current_user.id
      authorize(:indrel) or return
    end

    @person = Person.find(params[:resume][:person].to_i)
    params[:resume][:person] = @person

    unless resume_file = params[:resume][:file]
      flash[:notice] = "Please attach your resume file"
      @resume = Resume.new(params[:resume])
      @person = @current_user
      render :action => "new"
      return
    end

    resume_constructor_args = params[:resume]
    # strftime doesn't have milliseconds in ruby 1.8.7
    # So it will just put in an "L" in resume names for now
    # and when(?) we upgrade to 1.9+ it will start writing
    # times with milliseconds
    time_string = Time.new.strftime("%Y%m%d%H%M%S%L")
    if not Dir.entries("private/").include?("resumes")
      Dir.mkdir("private/resumes")
    end
    file_name = "private/resumes/#{time_string}_"+
                "#{@person.last_name}_" +
                "#{@person.first_name}.pdf"
    f = File.open(file_name, "wb")
    resume_constructor_args[:file] = file_name
    @resume = @person.resumes.new(resume_constructor_args)
    if @resume.save and not f.nil?
      f.write(resume_file.read)
      flash[:notice] = "Resume Uploaded"
      if @resume.person == @current_user
        redirect_to account_settings_path
      else # if this is an indrel officer uploading a resume on behalf of someone
        redirect_to resumes_path
      end
      # Delete all older resuems:
      old_resumes = @person.resumes[(1..-1)] # All but most recent res.
      old_resumes.each { |resume| @person.resumes.destroy(resume.id) }
    else
      render :action => "new"
    end
    if not f.nil?
      f.close
    end

  end
  
  def status_list
    @officers = Person.find(:all).find_all {|p| p.in_group?("officers")}
    @candidates = Person.find(:all).find_all {|p| p.in_group?("candidates")}
    @everyone_else = Person.find(:all).find_all {|p| not (@officers.include?(p) or @candidates.include?(p))}
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
