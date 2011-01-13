#!/usr/bin/env ruby

# This script will import course survey data from a tab-separated values 
# (TSV) file into the system.
#
# -richardxia

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../config/environment', __FILE__)

def parse_xsl filename
  puts "Not implemented yet"
end

# Expects line to be an array of ["String containing klass, section, and instructor", number of respondents, semester]
def parse_klass_info(line)
  #(dept_abbr, klass_section, instructor, title) = line[0].gsub(/^"(.*)"$/,'\1').split
  (dept_abbr, klass_section, instructor, title) = line[0].scan(
    /^"*(\w*)\s+([^\s]*)\s+(.*[^\s])\s*\((\w*)\)"*$/ ).first
  (full_course_number, section) = klass_section.split("-")
  if instructor.index(",").nil?
    puts "Could not parse instructor name #{instructor} correctly. Please check source file."
    exit
  end
  (last_name, first_name) = instructor.split(",")

  # Handles cases where an instructor has multiple parts to their name
  # i.e. El Ghaoui, Laurent
  # i.e. Chang-Hasnain, C.
  first_name = first_name.scan(/(\W+|\w+)/).map{|x| x.first.capitalize}.join
  last_name = last_name.scan(/(\W+|\w+)/).map{|x| x.first.capitalize}.join

  respondents = line[1]
  semester = line[11]
  full_course_number.upcase!

  # Check and find department
  department = Department.find_by_nice_abbr(dept_abbr)
  if department.nil?
    puts "Could not find department #{dept_abbr}. Please check the formatting of the input file."
    exit
  end

  # Check whether course exists
  (course_number, suffix) = full_course_number.match(/^([0-9]*)([A-Z]*)$/)[1..-1]
  course = Course.find(:first, :conditions => {:department_id => department.id, :course_number => course_number, :suffix => suffix})
  if course.nil?
    puts "Could not find course #{dept_abbr} #{full_course_number}. Please enter it into the database before rerunning this script" 
    exit
  end

  # Check whether instructor exists
  # I have no idea what we should do about duplicates. I'll probably want to see what the old script did
  # So many bad things can happen here if the survey does not format the instructor name properly
  instructor = Instructor.find(:first, :conditions => { :first_name => first_name, :last_name =>  last_name })
  
  if instructor.nil?
    puts "No instructor named #{first_name} #{last_name} found. Creating now."
    puts "If this is in error, please merge the instructor entries in the database."
    if title == "prof"
      privacy = false
    else
      privacy = true
    end
    instructor = Instructor.create( :first_name => first_name, :last_name => last_name, :private => privacy )
  end

  # Check whether klass exists, note that the EE survey results for TAs may not not follow the same section number convention as the other results
  formatted_semester = semester[-4..-1] + case semester[0..-6] when "SPRING" then "1" when "SUMMER" then "2" when "FALL" then "3" else "UNKNOWN" end
  klass = Klass.find( :first, :conditions => { :course_id => course.id, :semester => formatted_semester, :section => section } )
  if klass.nil?
    if title == 'ta'
      raise "Error: TA #{first_name} #{last_name} belongs to unknown section of #{course_number}"
    elsif title == 'prof'
      puts "No klass for #{semester} #{course.course_abbr} found. Creating new one."
      klass = Klass.create( :course_id => course.id, :semester => formatted_semester, :section => section )
    else
      raise "Error"
    end
  end

  # Check whether instructor is an instructor or a TA for the klass
  case title
  when "prof"
    klass.instructors << instructor unless klass.instructors.include? instructor
    klass.save
  when "ta"
    klass.tas << instructor unless klass.tas.include? instructor
    klass.save
  else
    raise "Error: Title #{title} not recognized. Should be either 'prof' or 'ta'"
  end

  return [1, instructor, klass]
end

def parse_frequencies
  return 3
end

def get_stats frequencies
  freq  = frequencies.reject {|key, value| key.class != Fixnum}
  sum   = freq.map{|key,value| key*value}.reduce{|x,y| x+y}
  count = freq.map{|key,value| value}.reduce{|x,y| x+y}
  if count == 0
    return [0, 0, 0]
  end

  mean = 1.0*sum/count
  entries = freq.map{|key,value| [key]*value}.flatten.sort
  median = (entries[count/2] + entries[-count/2])/2.0
  stddev = Math.sqrt(freq.map{|key,value| (key-mean)**2*value}.reduce{|x,y| x+y}/(count))
  [mean, median, stddev]
end

def parse_answers lines, i, instructor, klass, answers
  initial_line = i
  order = 0
  errors = false
  until lines[i] =~ /^Data processed:/
    if lines[i] =~ /^[0-9]*\./
      qa = lines[i].split("\t")
      question = qa[0].gsub(/^[0-9]*\. (.*)$/, '\1')
      q = SurveyQuestion.find_by_text(question)
      if q.nil?
        puts "Couldn't find survey question \"#{question}\". Please enter it into the database manually."
        errors = true
      elsif SurveyAnswer.find(:first, :conditions => {:instructor_id => instructor.id, :klass_id => klass.id, :survey_question_id => q.id})
        puts "Survey data already found. Not updating."
        exit
      else
        frequencies = {}
        1.upto(q.max) do |x|
          if qa[x] == ""
            value = 0
          else
            value = qa[x].to_i
          end
          frequencies[x] = value
        end
        frequencies["Omit"] = qa[9].blank? ? 0 : qa[9].to_i
        frequencies["N/A"]  = qa[8].blank? ? 0 : qa[8].to_i

        (mean, median, stddev) = get_stats(frequencies)
        answers << {
          :survey_question_id => q.id,
          :klass_id           => klass.id,
          :instructor_id      => instructor.id,
          :frequencies        => frequencies.to_json,
          :mean               => mean,
          :median             => median,
          :deviation          => stddev,
          :order              => order,
        }
        order += 1
      end
    end
    i += 1
  end
  exit if errors
  i += 1
  until (!lines[i].blank? and lines[i][0].chr == '"') or i >= lines.size
    i += 1
  end
  return i - initial_line
end

def parse_tsv filename
  # First we scan over the entire document to ensure that the data is formatted correctly
  # During this, we check whether each klass, professor, and question has been created already
  # We create hashes for each survey answer and store them in answers. After passing checks,
  # we save the answers into the database.
  file = File.open(filename, "r")
  i = 0
  lines = file.readlines

  answers = []
  while i < lines.size
    (lines_read, instructor, klass) = parse_klass_info(lines[i].split("\t"))
    i += lines_read

    i += parse_frequencies

    i += parse_answers(lines, i, instructor, klass, answers)
  end
  puts "Passed checks. Continuing with inserting results into database"
  answers.each do |answer|
    SurveyAnswer.create(answer)
  end
end

if ARGV.size == 0
  puts "You must specify a target course survey data file"
  puts "(Supported file formats: .xsl, /*.tsv*/)"
  exit
end

filename = ARGV[0]
file_format = filename.split(".").last
case file_format
when "xsl" then parse_xsl filename
else parse_tsv filename
end
