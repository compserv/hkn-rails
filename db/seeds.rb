# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)
def initialize_slots
  Slot::Hour::Valid.each do |hour|
    Slot::Wday::Valid.each do |wday|
      Slot::Room::Valid.each do |room|
        Slot.where(hour: hour, wday: wday, room: room).first_or_create
      end
    end
  end
end

def initialize_groups
  Committeeship.Committees.each do |c|
    Group.where(name: c, description: "The #{c} committee").first_or_create
  end

  groups = [
    {"name"=>"superusers","description"=>"Admin"},

    # Member types
    {"name"=>"members",    "description"=>"Members"},
    {"name"=>"candidates", "description"=>"Candidates"},
    {"name"=>"candplus",   "description"=>"Candidates and Members"},
    {"name"=>"officers",   "description"=>"Officers"},
    {"name"=>"assistants", "description"=>"Assistant Officers"},
    {"name"=>"comms",      "description"=>"Committee Members and Officers"},
    {"name"=>"cmembers",   "description"=>"Committee Members"},
    {"name"=>"alumni",     "description"=>"Alumni"},

    # Committees
    {"name"=>"pres",      "description"=>"President"},
    {"name"=>"vp",        "description"=>"Vice President"},
    {"name"=>"rsec",      "description"=>"Recording Secretary"},
    {"name"=>"csec",      "description"=>"Corresponding Secretary"},
    {"name"=>"opsec",     "description"=>"Operations Secretary"},
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
    {"name"=>"prodev",    "description"=>"Professional Development"},
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
    g = Group.find_or_create_by(group)
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
    {'name'=> 'Prodev'},
    {'name'=> 'Speaker Series'},
    {'name'=> 'Interactivities'},
  ]

  event_types.each do |event_type|
    EventType.find_or_create_by(event_type)
  end
end

def initialize_departments
  departments = [
    {'name'=>'Electrical Engineering', 'abbr'=>'EL ENG'},
    {'name'=>'Computer Science', 'abbr'=>'COMPSCI'}
  ]

  departments.each do |dept|
    Department.find_or_create_by(dept)
  end
end

def initialize_people
  [ [{first_name: 'Course', last_name: 'Surveys', username: 'coursesurveys', email: 'www-coursesurvey@hkn.eecs.berkeley.edu'}, ['coursesurveys']]
  ].each do |p, groups|
    purson = Person.where(p).first || Person.new(p.update({password: 'changeme', password_confirmation: 'changeme', approved: true}))
    purson.groups = groups.collect {|g| Group.find_by_name(g)}
    raise purson.errors.inspect unless purson.save
  end
end

def initialize_mobile_carriers
  mobile_carriers = [
    {name: "Alltel",             sms_email: "@message.alltel.com"},
    {name: "AT&T",               sms_email: "@txt.att.net"},
    {name: "Boost Mobile",       sms_email: "@myboostmobile.com"},
    {name: "Nextel",             sms_email: "@messaging.nextel.com"},
    {name: "Sprint",             sms_email: "@messaging.sprintpcs.com"},
    {name: "T-Mobile",           sms_email: "@tmomail.net"},
    {name: "US Cellular",        sms_email: "@email.uscc.net"},
    {name: "Verizon",            sms_email: "@vtext.com"},
    {name: "Virgin Mobile USA",  sms_email: "@vmobl.com"},
  ]
  mobile_carriers.each do |mobile_carrier|
    MobileCarrier.find_or_create_by(mobile_carrier)
  end
end


initialize_slots
initialize_groups
initialize_eventtypes
initialize_departments
initialize_people
initialize_mobile_carriers
