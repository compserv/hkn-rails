#!/usr/bin/env ruby

require File.expand_path('../../../config/environment', __FILE__)

f = File.open('company.json', 'r')
companies = ActiveSupport::JSON::decode(f)
f.close
f = File.open('contact.json', 'r')
contacts = ActiveSupport::JSON::decode(f)
f.close
f = File.open('event.json', 'r')
events = ActiveSupport::JSON::decode(f)
f.close
f = File.open('event_type.json', 'r')
event_types = ActiveSupport::JSON::decode(f)
f.close
f = File.open('location.json', 'r')
locations = ActiveSupport::JSON::decode(f)
f.close

# Lazy method for finding an object with given id
def find(collection, id, &predicate)
  # Default predicate is on id
  predicate ||= lambda {|x,y| x['id'] == y}
  collection.each do |object|
    object = object.values.first
    if predicate.call(object, id)
      return object
    end
  end
  return nil
end

# Dependencies (-> = "depends on"):
# contacts -> company
# event -> event_type, contact, location

companies.each do |company|
  # Weird to_json format stores each object as a hash of a hash
  company = company['company'].clone
  company.delete('id')
  Company.create!(company)
end

contacts.each do |contact|
  contact = contact['contact'].clone
  contact.delete('id')
  company_id = contact.delete('company_id')
  contact['company_id'] = Company.find_by_name(find(companies, company_id)['name']).id unless company_id.nil?
  Contact.create!(contact)
end

event_types.each do |event_type|
  event_type = event_type['event_type'].clone
  event_type.delete('id')
  IndrelEventType.create!(event_type)
end

locations.each do |location|
  location = location['location'].clone
  location.delete('id')
  Location.create!(location)
end

events.each do |event|
  event = event['event'].clone
  event.delete('id')
  company_id = event.delete('company_id')
  event['company_id'] = Company.find_by_name(find(companies, company_id)['name']).id unless company_id.nil?
  contact_id = event.delete('contact_id')
  event['contact_id'] = Contact.find_by_name(find(contacts, contact_id)['name']).id unless contact_id.nil?
  location_id = event.delete('location_id')
  event['location_id'] = Location.find_by_name(find(locations, location_id)['name']).id unless location_id.nil?
  event_type_id = event.delete('event_type_id')
  event['indrel_event_type_id'] = IndrelEventType.find_by_name(find(event_types, event_type_id)['name']).id unless event_type_id.nil?
  IndrelEvent.create!(event)
end
