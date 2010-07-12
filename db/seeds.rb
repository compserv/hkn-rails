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