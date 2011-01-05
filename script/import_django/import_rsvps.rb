#!/usr/bin/env ruby

require File.expand_path('../../../config/environment', __FILE__)

# Events and People must be imported before rsvps!!!
f = File.open('dumps/event.json', 'r')
events = ActiveSupport::JSON::decode(f)
f = File.open('dumps/person.json', 'r')
people = ActiveSupport::JSON::decode(f)
f = File.open('dumps/rsvp.json', 'r')
rsvps = ActiveSupport::JSON::decode(f)

rsvps.each do |id, rsvp|
  new_rsvp = {}
  event = events[rsvp['event_id'].to_s]
  event = Event.find_by_name_and_start_time(event['name'], event['start_time'])
  person = Person.find_by_username(people[rsvp['person_id'].to_s]['username'])

  if event.blank?
    puts "Cannot find event for Rsvp #{id}"
    next
  end
  if person.blank?
    puts "Cannot find person for Rsvp #{id}"
    next
  end

  new_rsvp['person']          = person
  new_rsvp['event']           = event
  new_rsvp['transportation']  = rsvp['transport']
  new_rsvp['comment']         = rsvp['comment']
  new_rsvp['confirmed']       = rsvp['vp_confirm']
  new_rsvp['confirm_comment'] = rsvp['vp_comment']

  r = Rsvp.new(new_rsvp)

  blocks = event.blocks.order(:start_time)
  if rsvp['rsvp_data'] == '' or rsvp['rsvp_data'].nil? or event.blocks.size == 1
    r.blocks = blocks
  else
    new_blocks = rsvp['rsvp_data'].map{|block_num| blocks[block_num.to_i]}
    r.blocks = new_blocks unless new_blocks.blank?
  end

  r.save
  if not r.valid?
    puts "rsvp.id: #{id}, event.id: #{event.id} - #{event.name} - #{event.start_time}"
    puts rsvp['rsvp_data']
    puts "Rsvp for #{person.fullname} could not be created"
    puts r.errors
    next
  end

end
