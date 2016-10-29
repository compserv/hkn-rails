class ResumeBooksController < ApplicationController

  before_filter :authorize_indrel, :except => [:download_pdf]

  before_filter :authorize_download, :only => [:download_pdf, :download_iso]

  def new
    @resume_book = ResumeBook.new
  end

  def create
    @resume_book_root = "private/resume_books"
    @gen_root = "#{@resume_book_root}/templates"
    res_book_params = params[:resume_book]
    @resume_book = ResumeBook.new(resume_book_params)
    @hash = get_hash
    @scratch_dir = "#{@resume_book_root}/#{@hash}_scratch"
    raise "Failed to make scratch dir" unless system "mkdir #{@scratch_dir}"
    cutoff_date = @resume_book.cutoff_date
    current_semester = Property.semester
    if current_semester[-1..-1] == 3 # Fall
      graduating_class = current_semester[0..3].to_i + 1
    else  # Spring or Summer
      graduating_class = current_semester[0..3].to_i
    end
    resumes = group_resumes(cutoff_date, graduating_class)
    indrel_officers = indrel_officer_names
    description = generate_description(resumes, cutoff_date, indrel_officers)
    temp_pdf_file = generate_pdf(resumes, cutoff_date, indrel_officers)
    temp_iso_file = generate_iso(resumes, cutoff_date, indrel_officers,
                                 temp_pdf_file)
    res_book_directory = "#{@resume_book_root}/#{@hash}_resume_book"
    raise "Failed to make book dir" unless system "mkdir #{res_book_directory}"
    pdf_file = "#{res_book_directory}/HKNResumeBook.pdf"
    iso_file = "#{res_book_directory}/HKNResumeBook.iso"
    raise "Failed to copy pdf" unless system "cp #{temp_pdf_file} #{pdf_file}"
    raise "Failed to copy iso" unless system "cp #{temp_iso_file} #{iso_file}"
#    cleanup
    @resume_book.details   = description
    @resume_book.directory = res_book_directory
    @resume_book.pdf_file  = pdf_file
    @resume_book.iso_file  = iso_file
    @resume_book.save!
    redirect_to resume_book_path(@resume_book.id)
  end

  def index
  end

  def show
    @resume_book = ResumeBook.find(params[:id])
    @companies = Company.ordered

    @company = Company.find(params[:company_id]) if params[:company_id]
  end

  # Missing gives the emails of officers and current candidates who are missing
  # a resume book so indrel can bug them.
  def missing
    # Getting the components of the cutoff date doesn't really work...

    # @cutoff_date = Date.new(params[:date]["cutoff_date(1i)"].to_i,params[:date]["cutoff_date(2i)"].to_i,params[:date]["cutoff_date(3i)"].to_i)
    @cutoff_date = (params[:date] && Date.send(:new, *params[:date].to_a.sort_by(&:first).collect(&:second).collect(&:to_i))) || Date.today

    officers, candidates = ['officers', 'candidates'].collect do |group_name|
      Group.find_by_name(group_name).people.order(:first_name).includes(:resumes)
    end

    # limit officers to current only
    officers &= Committeeship.current.officers.collect(&:person)

    @officers_without_resumes, @candidates_without_resumes = [officers,candidates].collect do |ppl|
      ppl.reject { |p| p.resumes.since(@cutoff_date).exists? }
    end

    @people_in_book = Resume.since(@cutoff_date).includes(:person).collect(&:person).uniq.sort_by(&:full_name)

  end

  # Copied from richardxia's code in the resume file
  # I'm not sure if this is secure

  # Shows resumebook (PDF, not model data) after authorization
  def download_pdf
    @resume_book = ResumeBook.find(params[:id])
    send_file @resume_book.pdf_file, :type => 'application/pdf', :x_sendfile => true
  end

  # Shows resumebook (ISO) after authorization
  def download_iso
    @resume_book = ResumeBook.find(params[:id])
    send_file @resume_book.iso_file, :type => 'application/octet-stream', :x_sendfile => true
  end

private

  def authorize_download
    unless (Company.find_by_single_access_token(params[:access_key]) &&
      CompanySession.find(params[:access_key])) ||
      (@current_user && @current_user.in_groups?(['superusers', 'indrel']))
      redirect_to :root, :notice => "Insufficient privileges to access this" \
        "page."
    end
  end


  def generate_pdf(resumes, cutoff_date, indrel_officers)
    # @scratch_dir is the scratch work directory
    res_book_pdfs = Array.new
    indrel_letter_template = "#{@gen_root}/indrel_letter.tex.erb"
    toc_template = "#{@gen_root}/table_of_contents.tex.erb"
    res_book_pdfs << "#{@gen_root}/skeleton/cover.pdf"
    system "cp #{@gen_root}/skeleton/hkn_emblem.png #{@scratch_dir}/"
    res_book_pdfs << process_tex_template(indrel_letter_template, binding)
    sorted_yrs = sorted_years(resumes) #used in table of contents template
    res_book_pdfs << process_tex_template(toc_template, binding)
    sorted_years(resumes).each do |year|
      res_book_pdfs << section_cover_page(year)
      resumes[year].each do |resume|
        res_book_pdfs << "\"#{resume.file.to_s}\""
      end
    end
    concatenate_pdfs(res_book_pdfs, "#{@scratch_dir}/HKNResumeBook.pdf")
  end

  # gets the file erb's it using do_erb and returns the location
  # of the result (which is put in the @scratch_dir directory)
  def process_tex_template(input_file_name, bindings)
    file_base_name_tex_erb = File.basename(input_file_name)
    file_base_name_tex = file_base_name_tex_erb[0..-5]
    file_base_name_pdf = file_base_name_tex[0..-5] + ".pdf"
    do_erb(input_file_name,"#{@scratch_dir}/#{file_base_name_tex}",bindings)
    do_tex("#{@scratch_dir}",file_base_name_tex)
    "#{@scratch_dir}/#{file_base_name_pdf}"
  end

  def nice_class_name(year)
    if year == :grads
      "Graduates"
    else
      "Class of #{year}"
    end
  end

  def do_erb(input_file_name, output_file_name, bindings)
    template_string = File.new(input_file_name).readlines.join("")
    template = ERB.new(template_string)
    f = File.new(output_file_name, "w")
    f.write(template.result(bindings))
    f.close
  end

  def do_tex(directory, file_name)
    Dir.chdir(directory) do |dir_name|
      raise "Failed to pdflatex #{file_name}" unless system "pdflatex #{file_name}"
    end
  end

  # year will be a year i.e. 2011 or :grads
  def section_cover_page(year)
    do_erb("#{@gen_root}/section_title.tex.erb",
           "#{@scratch_dir}/#{year.to_s}title.tex",
           binding)
    do_tex("#{@scratch_dir}","#{year.to_s}title.tex")
    "#{@scratch_dir}/#{year.to_s}title.pdf"
  end

  def concatenate_pdfs(pdf_file_list, output_file_name)
    concat_cmd = "pdftk #{pdf_file_list.join(' ')} cat output #{output_file_name}"
    logger.error "Failed to concat pdfs (#{concat_cmd})" unless system concat_cmd
    output_file_name
  end

  def generate_iso(resumes, cutoff_date, indrel_officers, res_book_pdf)
    # TODO there's some really shady stuff going on here..
    #      use Ruby libs to improve security
    dir_name_fn = lambda {|year| year == :grads ? "grads" : year.to_s }
    iso_dir = "#{@scratch_dir}/ResumeBookISO"
    raise "Failed to copy ISO dir" unless system "cp -R #{@gen_root}/skeleton/ResumeBookISO #{iso_dir}"
    system "sed \"s/SEMESTER/#{nice_semester}/g\" #{iso_dir}/Welcome.html > #{iso_dir}/Welcome.html.tmp"
    system "mv #{iso_dir}/Welcome.html.tmp #{iso_dir}/Welcome.html"
    system "mkdir #{iso_dir}/Resumes"
    resumes.each_key do |year|
      year_dir_name = "#{iso_dir}/Resumes/#{dir_name_fn.call(year)}"
      system "mkdir #{year_dir_name}"
      resumes[year].each do |resume|
        next unless resume.included?
        system "cp #{resume.file} \"#{year_dir_name}/#{resume.person.last_name}, #{resume.person.first_name}.pdf\""
      end
    end
    system "cp #{res_book_pdf} #{iso_dir}/HKNResumeBook.pdf"
    raise "Filed to genisoimage" unless system "genisoimage -V 'HKN Resume Book' -o #{@scratch_dir}/HKNResumeBook.iso -R -J #{iso_dir}"
    "#{@scratch_dir}/HKNResumeBook.iso"
  end

  # Stolen from committeeship. Why isn't this procedure in the property class?
  SEMESTER_MAP = { 1 => "Spring", 2 => "Summer", 3 => "Fall" }
  def nice_semester
    "#{SEMESTER_MAP[Property.semester[-1..-1].to_i]} #{Property.semester[0..3]}"
  end

  def setup

  end

  def cleanup
    raise "Failed to cleanup scratch dir" unless system "rm -rf #{@scratch_dir}"
  end

  # get the keys of resumes hash in correct order so we have increasing years
  # in resume book
  def sorted_years(resumes)
    grad_flag = resumes.keys.include?(:grads)
    sorted_yrs = resumes.keys.reject{|x| x.class == Symbol}
    sorted_yrs.sort!
    sorted_yrs << :grads if grad_flag
    sorted_yrs
  end

  def generate_description(resumes, cutoff_date, indrel_names)
    output_string = String.new
  end

  def group_resumes(cutoff_date, graduating_class)
    resumes = Hash.new

    Resume.since(cutoff_date).approved.each do |resume|
      # append to correct array
      if resume.graduation_year < graduating_class
        resumes[:grads] ||= []
      else
        resumes[resume.graduation_year] ||= []
      end << resume
    end

    # Now sort the resumes in each group by Last Name
    resumes.values.each { |a| a.sort_by! {|r| r.person.last_name} }
    return resumes
  end

  def indrel_officer_names
    Committeeship.current.committee("indrel").officers.map {
       |officer| "#{officer.person.first_name} #{officer.person.last_name}" }.sort
  end

  def get_hash
    Time.new.strftime("%Y%m%d%H%M%S%L")
  end

  private

    def resume_book_params
      params.require(:resume_book).permit(
        :remarks,
        :cutoff_date
      )
    end
end
