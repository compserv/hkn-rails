class LeaderboardController < ApplicationController
  before_filter :authorize_comms

  def index
    @people = Person.find(:all, :joins => "JOIN committeeships ON committeeships.person_id = people.id", :conditions => ["committeeships.semester = ? AND committeeships.title IN (?)", Property.semester, ["officer", "cmember"] ])
    @people_array = []
    @people.each do |person|
      @people_array << [person, person.rsvps.confirmed.joins(:event).where("events.start_time > ?", Property.semester_start_time).count]
    end

    @people_array.sort!{|a,b| a[1] <=> b[1]}
    @people_array.reverse!
  end
end
