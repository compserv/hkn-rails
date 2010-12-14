#!/usr/bin/env ruby
#
# TODO: Figure out if we want to store the following info:
# * Address
# * Graduating semester (this is probably a yes)
# * Privacy (we probably want to implement this)
# 
# Also figure out how we want to do other stuff
# * Officership/candidateship/cmembership
# * Pictures
# * Grad student?

require File.expand_path('../../../config/environment', __FILE__)

# People must be imported before committeeships!!!
# Note: We'll have to manually enter in the cmemberships for the past 
# several semesters
f = File.open('dumps/user.json', 'r')
users = ActiveSupport::JSON::decode(f)
f = File.open('dumps/position.json', 'r')
positions = ActiveSupport::JSON::decode(f)
f = File.open('dumps/officership.json', 'r')
officerships = ActiveSupport::JSON::decode(f)

def new_position_abbr(position)
  position_abbr_map = {
    'tutor' => 'tutoring',
    'alumadvisor' => 'alumadv',
    'facadvisor' => 'facadv',
  }
  if position_abbr_map.keys.include? position
    position_abbr_map[position]
  else
    position
  end
end

def new_semester(semester)
  season = semester[0..1]
  year = semester[2..3]
  new_season = case season when 'sp' then '1' when 'su' then '2' when 'fa' then '3' end
  new_year = (year.to_i < 20) ? '20'+year : '19'+year
  new_year+new_season
end

officerships.each do |id, officership|
  position = positions[officership['position_id'].to_s]
  user = users[officership['person_id'].to_s]
  if user.blank?
    puts "User id #{officership['person_id']} not found"
    next
  end
  username = user['username']
  new_person = Person.find_by_username(username)
  if new_person.blank?
    puts "User #{username} not found"
    next
  end
  new_person_id = new_person.id
  Committeeship.create( 
    :committee => new_position_abbr(position['short_name']),
    :semester => new_semester(officership['semester']),
    :person_id => new_person_id,
    :title => 'officer'
  )
end
