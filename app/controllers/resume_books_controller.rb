# TODO:
# Find indrel officer names indrel_officer_names()

require 'ERB'

class ResumeBooksController < ApplicationController
  
  before_filter :authorize_indrel
  
  def new
    @resume_book = ResumeBook.new
    
  end

  def create
    @resume_book_root = "private/resume_books"
    res_book_params = params[:resume_book]
    @resume_book = ResumeBook.new(res_book_params)
    @hash = self.get_hash
    @scratch_dir = "mkdir #{@resume_book_root}/#{@hash}_scratch"
    system "mkdir #{@scratch_dir}"
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
    temp_iso_file = generate_iso(resumes, cutoff_date, indrel_officers)
    # We'll use this for now, hopefully final website will run on 1.9.2
    res_book_directory = "#{@resume_book_root}/#{time_string}_resume_book"
    pdf_file = "#{res_book_directory}/resume_book.pdf"
    iso_file = "#{res_book_directory}/resume_book.iso"
    system "mkdir #{res_book_directory}"
    system "cp #{temp_pdf_file} #{pdf_file}"
    system "cp #{temp_iso_file} #{iso_file}"
#    cleanup
    @resume_book.details   = description
    @resume_book.directory = res_book_directory
    @resume_book.pdf_file  = pdf_file
    @resume_book.iso_file  = iso_file
    @resume_book.save!
  end

  def index
  end
  
  def show
    @resume_book = ResumeBook.find(params[:id])
  end

private

  def generate_pdf(resumes, cutoff_date, indrel_officers)
    gen_root = "#{@resume_book_root}/generation"
    scratch_dir = @scratch_dir
    # @scratch_dir is the scratch work directory
    cover = "#{gen_root}/skeleton/cover.pdf"
    res_book_pdfs = Array.new
    res_book_pdfs << cover
    do_erb("#{gen_root}/indrel_letter.tex.erb",
           "#{scratch_dir}/indrel_letter.tex",binding)
    do_tex("#{scratch_dir}/scratch","letter.tex")
    letter = "#{scratch_dir}/skeleton/indrel_letter.pdf"
    res_book_pdfs << letter
    
    concatenate_pdf(res_book_pdfs, "#{scratch_dir}/scratch/res_book.pdf")
    "#{scratch_dir}/scratch/res_book.pdf"
  end
  
  def do_erb(input_file_name, output_file_name, bindings)
    template_string = File.new(input_file_name).readlines.join("\n")
    template = ERB.new(template_string)
    f = File.new(output_file_name, "w")
    f.write(template.result(bindings))
    f.close
  end
  
  def do_tex(directory, file_name)
    Dir.chdir(directory) do |dir_name|
      system "pdflatex file_name"
    end
  end
  
  def concatenate_pdfs(pdf_file_list, output_file_name)
    template_string = File.new(input_file_name).readlines.join("\n")
    template = ERB.new(template_string)
    f = file.new(output_file_name)
    f.write(letter_template.result(bindings))
    f.close
  end
  
  def generate_iso(resumes, cutoff_date, indrel_officers)
    file_name = "#{@resume_book_root}/generation/scratch/iso_file.txt"
    f = File.new(file_name, "w")
    f.write("ISO File Stub\n")
    f.close
    file_name
  end
  
  def cleanup
    system "rm -rf #{@scratch_dir}"
  end
  
  def generate_description(resumes, cutoff_date, indrel_names)
    output_string = String.new
    output_string += "Current Indrel (signing the letter) are:\n"
    indrel_names.each do |indreller|
       output_string += indreller + "\n"
    end
    output_string += "\n\n"
    sorted_years = resumes.keys.reject{|x| x.class == Symbol}
    sorted_years.sort!
    sorted_years << :grads
    sorted_years.each do |group|
      if group == :grads
        output_string += "Graduates (Alumni)\n"
      else
        output_string += "Class of " + group.to_s + "\n"
      end
      output_string += "-------------------------------------\n"
      resumes[group].each do |resume|
        person = resume.person
        output_string += "#{person.last_name}, #{person.first_name}\n"
      end
      output_string += "\n\n"
    end
    output_string
  end
        
  def group_resumes(cutoff_date, graduating_class)
    resumes = Hash.new
    resumes[:grads] = Array.new
    # Resume.where wasn't working... when I figure that out I will replace the following
    Resume.find(:all).reject{|resume| resume.created_at < cutoff_date}.each do |resume|
      if resume.graduation_year < graduating_class
        resumes[:grads] << resume
      else
        if resumes[resume.graduation_year].nil?
          resumes[resume.graduation_year] = Array.new
        end
        resumes[resume.graduation_year] << resume
      end
    end
    # Now sort the resumes in each group by Last Name
    resumes.each do | year, res_array |
      res_array.sort! do |a,b| 
        if a.person.last_name.casecmp(b.person.last_name).zero?
          a.person.first_name.casecmp(b.person.first_name)
        else
          a.person.last_name.casecmp(b.person.last_name)
        end
      end
    end
    resumes
  end
  
  # Hardcoded for now -- should be fixed within the week
  def indrel_officer_names
    ["Akash Gupta", "Richard Lan", "Sameet Ramakrishnan", "Stephanie Ren"]
  end
  
  def get_hash
    Time.new.utc.strftime("%Y%m%d%H%M%S%L")
  end
    
end
