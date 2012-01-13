# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
def initialize_slots
  Slot::Hour::Valid.each do |hour|
    Slot::Wday::Valid.each do |wday|
      Slot::Room::Valid.each do |room|
        Slot.find_or_create_by_hour_and_wday_and_room(hour, wday, room)
      end
    end
  end
end

def initialize_groups
  Committeeship.Committees.each do |c|
    Group.find_or_create_by_name_and_description(:name=>c, :description=>"The #{c} committee")
  end

  groups = [
    {"name"=>"superusers","description"=>"Admin"},

    # Member types
    {"name"=>"members",   "description"=>"Members"},
    {"name"=>"candidates","description"=>"Candidates"},
    {"name"=>"candplus",  "description"=>"Candidates and Members"},
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

    # Misc. groups
    {'name'=>'coursesurveys', 'description'=>'Course surveys privileged access'},
  ]

  groups.each do |group|
    g = Group.find_or_create_by_name_and_description(group)
    g.update_attribute(:committee, true) if Committeeship.Committees.include? group['name']
  end
end

def initialize_eventtypes
  event_types = [
    {'name'=> 'Mandatory for Candidates'},
    {'name'=> 'Fun'},
    {'name'=> 'Big Fun'},
    {'name'=> 'Service'},
    {'name'=> 'Industry'},
    {'name'=> 'Exam'},
    {'name'=> 'Review Session'},
    {'name'=> 'Miscellaneous'},
  ]

  event_types.each do |event_type|
    EventType.find_or_create_by_name(event_type)
  end
end

def initialize_departments
  departments = [
    {'name'=>'Electrical Engineering', 'abbr'=>'EL ENG'},
    {'name'=>'Computer Science', 'abbr'=>'COMPSCI'}
  ]

  departments.each do |dept|
    Department.find_or_create_by_name_and_abbr(dept)
  end
end

def initialize_people
  [ [{:first_name => 'Course', :last_name => 'Surveys', :username => 'coursesurveys', :email => 'www-coursesurvey@hkn.eecs.berkeley.edu'}, ['coursesurveys']]
  ].each do |p, groups|
    purson = Person.find(:first, :conditions => p) || Person.new(p.update({:password => 'changeme', :password_confirmation => 'changeme', :approved => true}))
    purson.groups = groups.collect {|g| Group.find_by_name(g)}
    raise purson.errors.inspect unless purson.save
  end
end


initialize_slots
initialize_groups
initialize_eventtypes
initialize_departments
initialize_people
