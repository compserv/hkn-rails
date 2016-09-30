#!/usr/bin/env ruby

# This script purges fake candidates from the database.
# A fake candidate is a person that has not been approved and whose first and
# last names are the same.
# -twang

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../config/environment', __FILE__)

puts 'Please confirm termination of the following people:'
hit_list = []
Person.where('first_name = last_name').where(:approved => nil).sort.each do |person|
  begin
    puts "#{person.full_name} (Y/n)"
    response = gets
    response.strip!
    response.downcase!
  end while response != 'y' and response != 'n'
  if (response == 'y')
    person.destroy
    hit_list << person.full_name
  end
end
puts "#{'*' * 80}"
puts 'The following people have been terminated:'
hit_list.sort.each do |name|
  puts name
end
  
