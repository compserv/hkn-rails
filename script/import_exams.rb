#!/usr/bin/env ruby

# Usage: import_exams EXAM_DIRECTORY | EXAM
#
# This script will import exams from the specified folder, or the given exam
# if one is specified. Successfully imported exams will go into the
# ~hkn-rails/public/examfiles directory. Klasses must be imported prior to
# running the script by importing coursesurveys. Exams must be formatted
# as follow:
# 	<course abbr>_<semester>_<exam-type>[#][_sol].<filetype>
# For example, "cs61a_fa10_mt3.pdf" or "ee40_su05_f_sol.pdf".
#
# Supported filetypes: (TODO add more)
# 	.pdf
#
# -adegtiar


# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../config/environment', __FILE__)
require 'fileutils'

# Regex for verifying the file format
$filepattern = /[a-zA-Z]+\d+[a-zA-Z]*_(sp|fa|su)\d\d_(mt\d+|f|q\d+)(_sol)?.(\w)+$/
# Regex for tokenizing the file name

$tokenpattern = /([a-zA-Z]+)(\d+[a-zA-Z]*)_(sp|fa|su)(\d\d)_(mt|f|q)(\d)?(_sol)?.\w+$/

VALID_EXTENSIONS = ['pdf']
SUCCESS_DIR = File.join(::Rails.root.to_s, 'public', 'examfiles')


# Imports the exam at the given file path into the database. Also moves
# successfully imported exams in the given directory, if specified.
def import_exam(file_path, success_dir=nil)
  basedir = File.dirname(file_path)
  filename = File.basename(file_path)

  puts "importing #{filename} ..."

  if not isValidExamFile?(filename)
    return false
  end

  file_path = convertFile(file_path)
  filename = File.basename(file_path)

  # File should now be a properly formatted pdf file
  dept, course_num, season, year, exam_type_abbr, type_num, sol_flag = (
    filename.scan($tokenpattern)[0])
  semester = season + year
  dept.upcase!
  course_num.upcase!

  # Check if corresponding Course exists
  course = Course.find_by_short_name(dept, course_num)
  if course.nil?
    puts "\tcould not find course #{dept}#{course_num}"
    puts "\tadd the course and re-run the script."
    return false
  end

  # Check if the corresponding Klass exists
  klass = Klass.find_by_course_and_nice_semester(course, semester)
  if klass.nil?
    puts "\tcould not find klass #{course} #{semester}"
    puts "\tadd the klass and re-run the script."
    return false
  end

  exam_type = Exam.typeFromAbbr(exam_type_abbr)
  is_solution = !sol_flag.nil?

  # Check if the exam already exists
  exam = Exam.where(:klass_id => klass.id, :course_id => course.id,
                    :filename => filename, :exam_type => exam_type,
                    :number => type_num, :is_solution => is_solution)
  if exam.empty?
    puts "\texam not found. Adding to database."
    exam = Exam.new(:klass_id => klass.id, :course_id => course.id,
                    :filename => filename, :exam_type => exam_type,
                    :number => type_num, :is_solution => is_solution)
    success = exam.save
    if not success
      puts "\tproblems saving exam: #{exam.errors}"
    end
  else
    puts "\texam already exists."
    success = true
  end

  # Move the file if successful
  if success and success_dir
    FileUtils.mv(file_path, success_dir)
  end

  return success
end

# Ensures the file is correctly formatted and of a supported file type.
def is_valid_exam_file?(filename)
  if not $filepattern.match(filename)
    puts "\tinvalid file name: #{filename} - ignoring"
    return false
  end
  type = filename.split('.')[1]
  if not VALID_EXTENSIONS.include?(type)
    puts "\tunsupported file type: #{type} - ignoring"
    puts "\tsupported file types: #{VALID_EXTENSIONS}"
    return false
  else
    return true
  end
end

# Given a properly formatted file of a supported file type, makes the
# filename lowercase and converts it to pdf. Returns the new file path.
def convert_file(file_path)
  filename = File.basename(file_path)
  basedir = File.dirname(file_path)

  # Make sure the file is all lowercase, for consistency
  if filename =~ /[A-Z]/
    puts "\tRenaming to all lowercase"
    filename.downcase!
    new_path = File.join(basedir, filename)
    FileUtils.mv(file_path, new_path)
    file_path = new_path
  end

  description, type = filename.split('.')

  # TODO add conversion from other types
  return file_path
end

# Imports a directory of exam files. Moves files to 'dirname/successful'.
def import_exam_directory(dirname, success_dir=nil)
  puts "Importing exams from #{dirname}..."
  success_dir = File.join(dirname, 'successful') unless !success_dir.nil?
  puts "Successful imports will go into #{success_dir}"
  if not File.exist?(success_dir)
    puts "Could not find #{success_dir}. Creating now."
    FileUtils.mkdir(success_dir)
  end

  n_succeeded = 0
  n_failed = 0

  # Call importExam for each file in directory.
  Dir[File.join(dirname, '*')].each do |file_path|
    if File.file?(file_path)
      if importExam(file_path, success_dir)
        n_succeeded += 1
      else
        n_failed += 1
      end
    end
  end

  puts 'Done.'
  puts "#{n_succeeded} exams successful."
  puts "#{n_failed} exams failed."
end


file_or_dir = File.expand_path('~/examfiles/test') # testing default

# Error checking
if ARGV.size == 0
  puts 'You must specify an exam or directory.'
  puts "Supported filetypes: #{VALID_EXTENSIONS}"
  puts "Debugging: using default ~/examfiles/test"
# exit
elsif not Course.exists?
  abort 'No Courses found. Please import courses before re-running this script.'
elsif not Klass.exists?
  abort 'No Klasses found. Please import course surveys before re-running this script."'
elsif not File.exist?(file_or_dir = File.expand_path(ARGV[0]))
  abort "Could not find #{file_or_dir} - exiting."
end

puts "Creating output directory: #{SUCCESS_DIR}" unless File.exists?(SUCCESS_DIR)
FileUtils.mkdir_p(SUCCESS_DIR)

if File.file?(file_or_dir)
  import_exam(file_or_dir, SUCCESS_DIR)
else	# directory
  import_exam_directory(file_or_dir, SUCCESS_DIR)
end
