#!/usr/bin/env ruby

# This script will import course information parsed from the online course 
# catalog (http://sis.berkeley.edu/catalog/gcc_view_req?p_dept_cd=EECS)
# into the system. It does not do anything if it finds a course that's
# already in the system. We may want to later add a few lines of code
# that updates information if the course already exists
#
# -richardxia

require "net/http"

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../config/environment', __FILE__)

def parse_page(page_text, dept_abbr)
  department = Department.find_by_nice_abbr(dept_abbr)
  raise "Invalid department abbreviation: #{dept_abbr}" if department.nil?

  lines = page_text.split(/\n/)
  i = 0
  i += 1 while lines[i] != "<I>Lower Division Courses</I>"
  i += 2 # Kill an extra line containing just <P>
  while lines[i] != "<I>Upper Division Courses</I>"
    i += parse_course(lines, i, department)
    i += 1 # Also kill an extra line containing just <P>
  end
  i += 2 
  while lines[i] != "<I>Graduate Courses</I>"
    i += parse_course(lines, i, department)
    i += 1 # Also kill an extra line containing just <P>
  end
  i += 2 
  while lines[i] != "<I>Professional Courses</I>"
    i += parse_course(lines, i, department)
    i += 1 # Also kill an extra line containing just <P>
  end
  i += 2 
  while lines[i] != "</FONT>"
    i += parse_course(lines, i, department)
    i += 1 # Also kill an extra line containing just <P>
  end
end

# Returns the number of lines parsed
def parse_course(course_text, i, department)
  initial_line = i

  # Course number, title, and units
  (full_course_number, title, units) = course_text[i].scan(
    /^(?:<B>)*([^\.]*)\. &nbsp;([^\.]*)\. (?:\((.*)\) )*&nbsp;(?:<\/B>)*$/
    ).first
  raise "FormatError" if full_course_number.nil?
  i += 1

  # Hours of class per week or self-paced
  i += 1 if course_text[i] =~ /hour.*per week/ or 
    course_text[i] =~ /restrict/ or 
    course_text[i] =~ /Self-paced/ or 
    course_text[i] =~ /may be repeated for credit/ or 
    course_text[i] =~ /Individual research./

  # P/NP
  i += 1 if course_text[i] =~ /<I>passed\/not passed<\/I>/ or
    course_text[i] =~ /<I>satisfactory\/unsatisfactory<\/I>/

  prereqs = course_text[i].scan(/<I>Prerequisites: (.*)<\/I>/).first
  if !prereqs.nil?
    prereqs = prereqs.first # It really returns an array of arrays if not nil
    i += 1
  end

  # Former course name
  i += 1 if course_text[i] =~ /<I>Formerly.*<\/I>/

  description = course_text[i]
  i += 1

  # Semesters offered
  i += 1 unless course_text[i] =~ /\(^.*\)/

  # Professor, unless if we hit the next <P> tag
  i += 1 unless course_text[i] == "<P>"

  count = i - initial_line

  (prefix, course_number, suffix) = full_course_number.scan(/^([A-Z]*)([0-9]*)([A-Z]*)$/).first
  if course_number.nil?
    puts "Poorly formatted course number #{full_course_number}"
    return count
  end
  if Course.find( :first, :conditions => { :department_id => department.id, :course_number => course_number, :suffix => suffix, :prefix => prefix } ).nil?
    puts "Adding #{department.nice_abbrs.first} #{full_course_number}"
    a = Course.create(
      :course_number => course_number,
      :suffix => suffix,
      :prefix => prefix,
      :name => title,
      :description => description,
      :units => units,
      :prereqs => prereqs,
      :department_id => department.id
    )
    if !a.valid?
      puts "Could not save #{prefix}#{course_number}#{suffix} because"
      puts a.errors
    end
  end
  return count
end

CS_URL = "http://sis.berkeley.edu/catalog/gcc_list_crse_req?p_dept_name=Computer+Science&p_dept_cd=COMPSCI&p_path=l"
EE_URL = "http://sis.berkeley.edu/catalog/gcc_list_crse_req?p_dept_name=Electrical+Engineering&p_dept_cd=EL+ENG&p_path=l"

html = Net::HTTP.get(URI.parse(CS_URL))
parse_page(html, "CS")
html = Net::HTTP.get(URI.parse(EE_URL))
parse_page(html, "EE")
