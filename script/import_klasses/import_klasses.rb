#!/usr/bin/env ruby

# This script will import klass data from a json file. Parts of this script
# were taken from richardxia's import_coursesurveys script.
#
# -adegtiar


# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../../config/environment', __FILE__)

# Finds an instructor with the given last name and first initial(s)
def get_instructor(first_initials, last_name)
    # TODO check by first initial
    instructors = Instructor.find_all_by_last_name(last_name)
    instructors.reject do |instructor|
      instructor.first_name.empty? or instructor.first_name[0] != first_initials[0]
    end
    if !instructors.empty?
      return instructors[0]
    end
end

def create_instructor()
  # Get the instructor's name from user input
  begin
    print "Please enter the instructor's first name: "
    STDOUT.flush
    first_name = STDIN.gets.chomp
  end while first_name.empty?
  begin
    print "Please enter the instructor's last name: "
    STDOUT.flush
    last_name = STDIN.gets.chomp
  end while last_name.empty?
  begin
    print "Should the instructor's ratings be hidden? [y/n]: "
    STDOUT.flush
    hidden = STDIN.gets.chomp
  end while !(hidden == 'y' or hidden == 'n')

  if hidden == 'y'
    ratings = 'private'
  else
    ratings = 'public'
  end

  puts "Creating instructor #{first_name} #{last_name} with #{ratings} ratings."
  return Instructor.create( :first_name => first_name, :last_name => last_name, :private => (hidden == 'y'))

end

# imports a klass given a dictionary of klass data, a department, and a
# formatted semester.
def import_klass(klass_dict, department, semester)
  prefix = klass_dict['course_prefix']

  # Strip off 'C' prefix of cross-listed courses
  if prefix == 'C'
    prefix = ''
  end

  number = klass_dict['course_number']
  suffix = klass_dict['course_suffix']
  section = klass_dict['section'].to_i
  location = klass_dict['location']
  notes = klass_dict['section_note']
  time = klass_dict['times']
  course_pretty_print = "#{department.nice_abbrs[0]} #{prefix}#{number}#{suffix}"

  # Check whether course exists
  course = Course.find(:first, :conditions => {:department_id => department.id, :course_number => number, :suffix => suffix, :prefix => prefix})
  if course.nil?
    puts "WARN: Could not find course #{course_pretty_print}. Please enter it into the database before re-running this script."
    return
  end

  # Check whether instructor exists
  instructors = []
  klass_dict['instructors'].each do |instructor_dict|
    first_initials = instructor_dict['first']
    last_name = instructor_dict['last']
    instructor = get_instructor(first_initials, last_name)

    if instructor.nil?
      puts "WARN: No instructor named #{first_initials} #{last_name} found (teaching #{course_pretty_print}). Please enter the name of the instructor manually to create a new instructor in the database."
      instructor = create_instructor()
    end
    instructors << instructor
  end

  # Check whether klass exists
  klass = Klass.find( :first, :conditions => { :course_id => course.id, :semester => semester, :section => section } )
  if klass.nil?
    klass = Klass.create( :course_id => course.id, :semester => semester, :section => section, :location => location, :time => time, :notes => notes )
    puts "No klass for #{course_pretty_print} #{klass.proper_semester} found. Creating new one."
  else
    puts "Found klass #{course_pretty_print} #{klass.proper_semester}. Updating."
  end

  instructors.each do |instructor|
    klass.instructors << instructor unless klass.instructors.include? instructor
  end

  return klass.save
end

# Imports a list of klass data dicts for a particular department and semester.
def import_department(dept_abbr, klasses_for_dept, semester)

  # Check and find department
  department = Department.find_by_abbr(dept_abbr)
  if department.nil?
    abort "Could not find department #{dept_abbr}. Please check the formatting of the input file and verify that the database is seeded."
  end
  puts "Importing department: #{dept_abbr}"

  klasses_for_dept.each do |klass_dict|
    import_klass(klass_dict, department, semester)
  end
end

# Imports klass data given the name of the json data file.
def parse_klass_json(json_file_path)
  json_string = IO.read(json_file_path)
  klass_data = ActiveSupport::JSON.decode(json_string)
  season= klass_data['season']
  year = klass_data['year']
  formatted_semester = Klass.semester_code_from_s("#{season} #{year}")
  klass_data['departments'].each do |dept_abbr, klasses_for_dept|
    import_department(dept_abbr, klasses_for_dept, formatted_semester)
  end
end


if ARGV.size == 0
  abort "You must specify a target course klass json data file"
elsif not File.exist?(file_or_dir = File.expand_path(ARGV[0]))
  abort "Could not find #{file_or_dir} - exiting."
end

parse_klass_json(ARGV[0])

