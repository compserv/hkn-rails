class ResumesController < ApplicationController
  
  before_filter :authorize_indrel, :only => [:index, :resume_books]
  
  def new
    @resume = Resume.new
  end
  
  def create
    @resume = @current_user.resumes.new(params[:resume])
    resume_file = params[:resume][:file]
    # strftime doesn't have milliseconds in ruby 1.8.7
    time_string = Time.new.utc.strftime("%Y%m%d%H%M%S%L")
    # Why did they use random strings on the django site??
    file_name = "private/resumes/#{time_string}_"+
                "#{@current_user.last_name}_" +
                "#{@current_user.first_name}.pdf"
    f = File.open(file_name, "wb")
    if @resume.save
      @resume.file = f
      @resume.save! # This should always work if 2 lines above worked
      # Save file to disk only if it's valid
      f.write(resume_file.read)
      flash[:notice] = "Resume Uploaded"
      redirect_to account_settings_path
    else
      render :action => "new"
    end
    if not f.nil?
      f.close
    end
  end
  
  def index
    members_group = Group.where(:name => "members").first # 16
    candidates_group = Group.where(:name => "candidates").first # 17
    officers_group = Group.where(:name => "officers").first # 18
    comms_group = Group.where(:name => "committees").first #19
    people = Person.find(:all)
    @resinfo = Hash.new
    people.each do |person|
      if person.resumes.first :
        resume = person.resumes.first
        @resinfo[person] = {:upload => "Uploaded at #{resume.created_at}", 
                            :gpa => "#{resume.overall_gpa}" }
      else
        @resinfo[person] = {:upload =>"No resume uploaded", :gpa => ""}
      end
    end
  end
  
  private
  
  def most
  end

end
