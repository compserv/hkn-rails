#!/usr/bin/env ruby

# Outputs a JSON format of candidate names, local addresses, and permanent
# addresses as well as expected graduation semesters.
# - jkhoe 

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
require File.expand_path('../../config/environment', __FILE__)

candidate_group = Group.find_by_name("candidates")

puts '['
candidate_group.people.where(:approved => true).each do |person|
  info = '["' + person.full_name + '","' + person.local_address + '","' + person.perm_address + '","' + person.grad_semester + '"],'
  puts info
end
puts ']'
