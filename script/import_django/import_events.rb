#!/usr/bin/env ruby

require File.expand_path('../../../config/environment', __FILE__)

# People must be imported before committeeships!!!
# Note: We'll have to manually enter in the cmemberships for the past 
# several semesters
f = File.open('dumps/event.json', 'r')
events = ActiveSupport::JSON::decode(f)

def new_event_type(event_type)
  event_map = {
    'CANDMAND' => 'Mandatory for Candidates',
    'FUN' => 'Fun',
    'BIGFUN' => 'Big Fun',
    'COMSERV' => 'Community Service',
    'DEPSERV' => 'Department Service',
    'JOB' => 'Industry',
    'MISC' => 'Miscellaneous',
  }
  event_map[event_type]
end

events.each do |id, event|
  new_event = {}
  new_event['name']          = event['name']
  new_event['slug']          = event['slug']
  new_event['location']      = event['location']
  new_event['description']   = event['description']
  new_event['start_time']    = event['start_time']
  new_event['end_time']      = event['end_time']
  new_event['event_type_id'] = EventType.find_by_name(new_event_type(event['event_type'])).id
  new_event['need_transportation'] = event['rsvp_transportation_necessary']

  if not Event.create(new_event)
    puts "Event #{event['name']} could not be created"
  end
end
