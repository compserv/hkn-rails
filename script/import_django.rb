require 'json'

people = {}
File.open('auth.json', 'r') do |f|
  t = f.read
  obj = JSON::load t
  obj.each do |entry|
    if entry["model"] == "auth.user"
	  people[entry["pk"]]  = {:username => entry["fields"]["username"], :first => entry["fields"]["first_name"], :last => entry["fields"]["last_name"], :email => entry["fields"]["email"]}
	end
  end
end
p people
File.open('info.json', 'r') do |f|
  t = f.read
  obj = JSON::load t
  positions = []
  obj.each do |line|
	if line["model"] == "info.position"
	  positions[line["pk"]] = line["fields"]["short_name"]
	end
    if line["model"] == "info.officership"
	  p people[line["fields"]["person"]]
	  p positions[line["fields"]["position"]], line["fields"]["semester"]
	end
  end
  p positions
end