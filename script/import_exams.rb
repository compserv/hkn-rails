#!/usr/bin/env ruby

# Usage: import_exams EXAM_DIRECTORY || EXAM 
# This script will import exams from the specified folder, or the given
# exam if one is specified. Klasses must be imported prior to running the
# script by importing coursesurveys. Exams must be formatted as follows:
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

$filepattern = /[a-zA-Z]+\d+[a-zA-Z]*_(sp|fa|su)\d\d_(mt\d+|f|q\d+)(_sol)?$/
VALID_EXTENSIONS = ['pdf']
d = 3

def createExamForKlass(klass, exam_type, number, is_solution)
  course = klass.course
  if exam_type == 0 then
    type = "q"
  elsif exam_type == 1 then
    type = "mt"
  elsif exam_type == 2 then
    type = "f"
  end
  filename = "#{course.course_abbr}_#{klass.semester}#{klass.time}#{type}#{number}.pdf"
end

def importExam(file_path, success_dir=nil)
  basedir = File.dirname(file_path)
  filename = File.basename(file_path)

  puts "Importing #{filename} ..."

  if not isValidFile?(filename)
    puts "\tinvalid file name: #{filename} - ignoring"
    return false
  elsif not convertFile(filename, basedir)
    return false
  end

  # file should now be a valid pdf
  description = filename.split('.')[0]

  course_abbr, semester, exam_abbr, sol_flag = description.split('_')
  dept_abbr = course_abbr[0..1]
  course_number = course_abbr[2, course_abbr.length]
  # TODO optimize this to not do two separate lookups
  dept_abbr.upcase!
  course_number.upcase!
  course = Course.find_by_short_name(dept_abbr, course_number)
  puts "Course: #{course}"
  if course.nil?
    puts "\tCould not find course #{dept_abbr}#{course_number}"
    puts "\tAdd the course and re-run the script."
    return false
  end
  klass = Klass.find_by_course_and_nice_semester(course, semester)
  puts "Klass: #{klass}"
  if klass.nil?
    puts "\tCould not find klass #{course} #{semester}"
    puts "\tAdd the klass and re-run the script."
    return false
  end
  
  return false
end

def isValidFile?(filename)
  name_type = filename.split('.')
  return name_type.length == 2 && name_type[0] =~ $filepattern
end

def convertFile(filename, basedir)
  description, type = filename.split('.')

  if not VALID_EXTENSIONS.include?(type)
    return false
  end

  if description =~ /[A-Z]/
    puts "\tRenaming to all lowercase"
    description = description.downcase
    new_name = "#{description}.#{type}"
    new_path = File.join(basedir, new_name)
    old_path = File.join(basedir, filename)
    puts new_path
    puts old_path
    FileUtils.mv(old_path, new_path)
    filename = new_name
  end
  
  # TODO add conversion from other types
  return true
end

def checkFileType(file_path)
  if not checkFileType(file_path, file_type)
    puts "\tunsupported filetype: #{fileItype} - ignoring"
    return
  end
end

def importExamDirectory(dirname)
  puts "Importing exams from #{dirname}..."
  success_dir = File.join(dirname, 'successful')
  n_succeeded = 0
  n_failed = 0
  Dir[File.join(dirname, '*')].each do |file_path|
    if File.file?(file_path)
      if importExam(file_path, success_dir)
        n_succeeded += 1
      else
        n_failed += 1
      end
    else
      puts "Ignoring \"#{file_path}\" (not a file)."
    end
  end

  puts 'Done.'
  puts "#{n_succeeded} exams successful"
  puts "#{n_failed} exams failed."
end



if ARGV.size == 0
  puts 'You must specify an exam or directory.'
  puts 'Supported filetypes: .pdf'
  exit
end
  
if not Klass.exists?
  abort 'No Klasses found. Please import course surveys before re-running this script."'
end

file_or_dir = ARGV[0]
if not File.exists?(file_or_dir)
  abort "Could not find #{file_or_dir} - exiting."
elsif File.file?(file_or_dir)
  importExam(file_or_dir)
else	# directory
  importExamDirectory(file_or_dir)
end
