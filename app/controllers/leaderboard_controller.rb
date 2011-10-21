class LeaderboardController < ApplicationController
  before_filter :authorize_comms

  def index
    @people = Person.find(:all, :joins => "JOIN committeeships ON committeeships.person_id = people.id", :conditions => ["committeeships.semester = ? AND committeeships.title IN (?)", Property.semester, ["officer", "cmember"] ])
    @people_array = []
    @people.each do |person|
      # Makeshift data structure
      events = person.rsvps.confirmed.joins(:event).where("events.start_time > ?", Property.semester_start_time)
      @people_array << {
        :person => person, 
        :total => events.count,
        :events => events
      }
    end

    @people_array.each do |entry|
      entry[:big_fun] = entry[:events].where("events.event_type_id = ? ", EventType.find_by_name("Big Fun")).count
      entry[:fun] = entry[:events].where("events.event_type_id = ? ", EventType.find_by_name("Fun")).count
      entry[:service] = entry[:events].where("events.event_type_id = ? ", EventType.find_by_name("Service")).count

      entry[:score] = 2*entry[:big_fun] + entry[:fun] + 3*entry[:service]
    end

    @people_array.sort!{|a,b| a[:score] <=> b[:score]}
    @people_array.reverse!
    rank = 0
    last_num = -1
    incr = 1
    @people_array.each do |entry|
      if last_num != entry[:score]
        rank += incr
        last_num = entry[:score]
        incr = 0
      end
      entry[:rank] = rank
      incr += 1
    end
  end
end
