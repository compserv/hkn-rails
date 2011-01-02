# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
(11..16).each do |hour|
  (1..5).each do |day|
    Slot.find_or_create_by_time_and_room(:time=>Slot.get_time(day, hour), :room=>0)
    Slot.find_or_create_by_time_and_room(:time=>Slot.get_time(day, hour), :room=>1)
  end
end

Committeeship.Committees.each do |c|
  Group.find_or_create_by_name_and_description(:name=>c, :description=>"The #{c} committee")
end

groups = [
  {"name"=>"superusers","description"=>"Admin"},

  # Member types
  {"name"=>"members",   "description"=>"Members"},
  {"name"=>"candidates","description"=>"Candidates"},
  {"name"=>"officers",  "description"=>"Officers"},
  {"name"=>"comms",     "description"=>"Committee Members and Officers"},
  {"name"=>"cmembers",  "description"=>"Committee Members"},
  {"name"=>"alumni",    "description"=>"Alumni"},

  # Committees
  {"name"=>"pres",      "description"=>"President"},
  {"name"=>"vp",        "description"=>"Vice President"},
  {"name"=>"rsec",      "description"=>"Recording Secretary"},
  {"name"=>"csec",      "description"=>"Corresponding Secretary"},
  {"name"=>"treas",     "description"=>"Treasury"},
  {"name"=>"deprel",    "description"=>"Department Relations"},
  {"name"=>"serv",      "description"=>"Service"},
  {"name"=>"indrel",    "description"=>"Industrial Relations"},
  {"name"=>"bridge",    "description"=>"Bridge"},
  {"name"=>"act",       "description"=>"Activities"},
  {"name"=>"compserv",  "description"=>"Computer Services"},
  {"name"=>"studrel",   "description"=>"Student Relations"},
  {"name"=>"tutoring",  "description"=>"Tutoring"},
  {"name"=>"alumrel",   "description"=>"Alumni Relations"},
  {"name"=>"alumadv",   "description"=>"Alumni Advisor"},
  {"name"=>"facadv",    "description"=>"Faculty Advisor"},

  # Dissolved committees
  {"name"=>"pub",       "description"=>"Publicity"},
  {"name"=>"examfiles", "description"=>"Exam Files"},
  {"name"=>"ejc",       "description"=>"EJC Representative"},
]

groups.each do |group|
  Group.find_or_create_by_name_and_description(group)
end

event_types = [
  {'name'=> 'Mandatory for Candidates'},
  {'name'=> 'Fun'},
  {'name'=> 'Big Fun'},
  {'name'=> 'Service'},
  {'name'=> 'Industry'},
  {'name'=> 'Miscellaneous'},
]

event_types.each do |event_type|
  EventType.find_or_create_by_name(event_type)
end
