#!/usr/bin/env ruby

# Given a file containing full names, returns the corresponding emails.
# Takes one argument, the path to the file containing full names.
# The file should be formatted such that first names are separated from last
# names by a tab character ("\t").  (Some people have many parts to their
# first names / multiple last names separated by spaces.)  (Spreadsheets
# saved as text files work well for this purpose.)
# If a person with the given first and last name can't be found in the database,
# prints an error message saying so.
# If you want to save the emails output by the script in a file, you should
# probably check that every line in the file is actually an email address.
# (The first line of the file is going to be "SSL = true", so you will want to
# get rid of that, too.)
#
# -twang

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
require File.expand_path('../../config/environment', __FILE__)

file = File.new(ARGV[0])
while (full_name = file.gets)
  full_name_array = full_name.split("\t")
  first_name = full_name_array[0].strip
  last_name = full_name_array[1].strip
  person = Person.find_by_first_name_and_last_name(first_name, last_name)
  if (person.blank?)
    puts "#{full_name.strip} couldn't be found"
  else
    puts "#{person.email}"
  end
end
