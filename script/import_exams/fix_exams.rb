#!/usr/bin/env ruby

# Usage: fix_exams.rb EXAM_DIRECTORY
#
# This script will fix exams in the specified folder. Exams will be copied to
# one of several folders, depending on success or error. These folders will be
# under $RAILS_ROOT/scripts/import_exams/processed_exams. Klasses must be
# imported prior to running the script by importing coursesurveys. Exams must
# be formatted as follow:
# 	<course abbr>_<semester>_<exam-type>[#][_sol].<filetype>
# For example, "cs61a_fa10_mt3.pdf" or "ee40_su05_f_sol.pdf".
#
# Supported filetypes: (TODO add more)
# 	pdf txt
#
# -adegtiar


# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../../config/environment', __FILE__)
require 'fileutils'

# Regex for verifying the file format
$filepattern = /[a-zA-Z]+\d+[a-zA-Z]*_(sp|fa|su)\d\d_(mt\d+|f|q\d+)(_sol)?\.(\w)+$/
# Regex for tokenizing the file name

$tokenpattern = /([a-zA-Z]+)(\d+[a-zA-Z]*)_(sp|fa|su)(\d\d)_(mt|f|q)(\d)?(_sol)?\.\w+$/

VALID_EXTENSIONS = ['pdf', 'txt']
PROCESSED_EXAMS_DIR = File.join(::Rails.root.to_s, 'script', 'import_exams', \
                               'processed_exams')
# Results of processing an exams. These correspond to directories.
IMPROPER_NAME = 'improper_name'
UNSUPPORTED_FILE_TYPE = 'unsupported_file_type'
COURSE_NOT_FOUND = 'course_not_found'
KLASS_NOT_FOUND = 'klass_not_found'
EXAM_EXISTS = 'duplicates'
SUCCESS = 'success'
RESULTS = [IMPROPER_NAME, UNSUPPORTED_FILE_TYPE, COURSE_NOT_FOUND, \
  KLASS_NOT_FOUND, EXAM_EXISTS, SUCCESS]

# Returns the new name of the file, and the result of processing the exam. 
def fix_exam(file_path)
  basedir = File.dirname(file_path)
  filename = File.basename(file_path)

  # Make the filename all lowercase
  file_path = get_lowercase_name(file_path)

  # Hack - remove trailing '_' from filename
  # Old exams are commonly like this, for some reason
  file_path = remove_trailing_underscore(file_path)

  filename = File.basename(file_path)

  if not is_valid_file_name?(filename)
    return filename, IMPROPER_NAME
  end

  # File should now be a properly formatted file
  dept, course_num, season, year, exam_type_abbr, type_num, sol_flag = (
    filename.scan($tokenpattern)[0])
  semester = season + year
  dept.upcase!
  course_num.upcase!

  # Check if corresponding Course exists
  course = Course.lookup_by_short_name(dept, course_num)
  if course.nil?
    return filename, COURSE_NOT_FOUND
  end

  # Check if the corresponding Klass exists
  klass = Klass.find_by_course_and_nice_semester(course, semester)
  if klass.nil?
    return filename, KLASS_NOT_FOUND
  end

  exam_type = Exam.typeFromAbbr(exam_type_abbr)
  is_solution = !sol_flag.nil?

  # Check if the exam already exists
  exam = Exam.where(:klass_id => klass.id, :course_id => course.id,
                    :filename => filename, :exam_type => exam_type,
                    :number => type_num, :is_solution => is_solution)
  if !exam.empty?
    return filename, EXAM_EXISTS
  end

  # Extension not in supported file types
  if not is_supported_file_type?(filename)
    return filename, UNSUPPORTED_FILE_TYPE
  end

  # Success
  return filename, SUCCESS
end

# Ensures the file name is correctly formatted.
def is_valid_file_name?(filename)
  return $filepattern.match(filename)
end

# Ensures the file is of a supported file type.
def is_supported_file_type?(filename)
  type = filename.split('.')[1]
  return VALID_EXTENSIONS.include?(type)
end

# Given a properly formatted file of a supported file type, makes the
# filename lowercase and converts it to pdf. Returns the new file path.
def get_lowercase_name(file_path)
  filename = File.basename(file_path)
  basedir = File.dirname(file_path)

  # Make sure the file is all lowercase, for consistency
  filename.downcase!
  new_path = File.join(basedir, filename)
  file_path = new_path

  return file_path
end

def remove_trailing_underscore(file_path)
  filename, extension = File.basename(file_path).split('.')
  basedir = File.dirname(file_path)

  # Not a proper name. Give up.
  if extension == nil
    return file_path
  end

  if filename[-1,1] == '_'
    filename.chop!
  end

  # Make sure the file is all lowercase, for consistency
  filename.downcase!
  new_path = File.join(basedir, "#{filename}.#{extension}")

  return new_path
end

# Imports a directory of exam files. Moves files to 'dirname/successful'.
def fix_exam_directory(dirname, processed_dir)
  puts "Importing exams from #{dirname}..."
  puts "Processed exams will go into #{processed_dir}"
  if not File.exist?(processed_dir)
    puts "Could not find #{processed_dir}. Creating now."
    FileUtils.mkdir(processed_dir)
  end

  # Call importExam for each file in directory.
  Dir[File.join(dirname, '*')].each do |file_path|
    if File.file?(file_path)
      new_name, result = fix_exam(file_path)
      new_dir = File.join(processed_dir, result)
      FileUtils.mkdir_p(new_dir)
      new_path = File.join(new_dir, new_name)
      puts "#{new_name}\t-\t#{result}"
      if new_path != file_path
        FileUtils.cp(file_path, new_path)
      end
    end
  end

  puts "Done. Processed exams have been copied to #{processed_dir}."
  puts "Run import_exam.rb to import successfully processed exams."
end

# Error checking
if ARGV.size == 0
  puts 'You must specify a directory of exam files.'
  puts "Supported filetypes: #{VALID_EXTENSIONS}"
  exit
elsif not Course.exists?
  abort 'No Courses found. Please import courses before re-running this script.'
elsif not Klass.exists?
  abort 'No Klasses found. Please import course surveys before re-running this script."'
elsif not File.exist?(exam_dir = File.expand_path(ARGV[0]))
  abort "Could not find #{exam_dir} - exiting."
end

if File.directory?(exam_dir)
  FileUtils.mkdir_p(PROCESSED_EXAMS_DIR)
  fix_exam_directory(exam_dir, PROCESSED_EXAMS_DIR)
else
  abort "Could not find directory #{exam_dir}"
end
