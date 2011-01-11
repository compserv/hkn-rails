#!/usr/bin/env ruby

require File.expand_path('../../../config/environment', __FILE__)

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

  #new_event['view_permission'] = 
  #new_event['rsvp_permission'] = 

  e = Event.create(new_event)
  if not e.valid?
    puts "Event #{event['name']} could not be created"
    puts e.errors
    next
  end

  #puts "#{e.id} - #{e.name}: #{e.start_time}-#{e.end_time}"

  # RSVP_TYPE:
  # 0 = no rsvps
  # 1 = whole
  # 2 = block

  # Create blocks if RSVPing is allowed
  case event['rsvp_type']
  when 1
    #puts "singleton: #{event['start_time']} - #{event['end_time']}"
    Block.create!(:event => e, :start_time => event['start_time'], :end_time => event['end_time'])
  when 2
    # Note: Time.zone must be left as its default value of UTC

    start_time = Time.zone.parse(event['start_time'])
    #puts "#{event['start_time']} => #{start_time}"
    end_time = Time.zone.parse(event['end_time'])
    #puts "#{event['end_time']} => #{end_time}"

    num_blocks = ( (end_time - start_time)/event['rsvp_block_size'].minutes ).ceil
    (0..(num_blocks-1)).each do |block_num|
      block_start_time = start_time + block_num * event['rsvp_block_size'].minutes
      block_end_time = start_time + (block_num+1)*event['rsvp_block_size'].minutes
      block_end_time = event['end_time'] if block_end_time > end_time
      #puts "#{block_start_time} - #{block_end_time}"
      Block.create!(:event => e, :start_time => block_start_time, :end_time => block_end_time)
    end
  end
end
