class LeaderboardController < ApplicationController
  before_filter :authorize_comms

  def index
    @semester = params[:semester] || Property.current_semester
    @people = Person.joins(:committeeships)
                    .where("committeeships.semester = ? AND committeeships.title IN (?)", @semester, ["officer", "cmember"]).uniq
    @people_array = []
    #moar_people = [ 'eunjian' ].collect{|u|Person.find_by_username(u)}   # TODO remove when we have leaderboard opt-in
    @people.each do |person|
      # Makeshift data structure
      events = person.rsvps.confirmed.joins(:event).where("events.start_time > ? AND events.start_time < ?", Property.semester_start_time(@semester), Property.semester_start_time(Property.next_semester(@semester)))
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
      #if entry[:person].username == "eunjian"
      #  rand = Random.new()
      #  entry[:big_fun] = rand.rand(3..10)
      #  entry[:fun] = rand.rand(30..100)
      #  entry[:service] = rand.rand(5..15)
      #end
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
