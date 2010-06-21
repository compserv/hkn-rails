require 'json'

File.open('info.json', 'r') do |f|
  t = f.read
  obj = JSON::load t
  #p obj
  p obj.class
  positions = []
  obj.each do |line|
	if line["model"] == "info.position"
	  positions[line["pk"]] = line["fields"]["short_name"]
	end
    if line["model"] == "info.officership"
	  p positions[line["fields"]["position"]], line["fields"]["semester"]
	end
  end
  p positions
end