require 'json/pure'

people = {}
positions = []

File.open('auth.json', 'r') do |f|
  t = f.read
  obj = JSON::load t
  obj.each do |entry|
    if entry["model"] == "auth.user"
      person  = {:username => entry["fields"]["username"],
        :first_name => entry["fields"]["first_name"],
        :last_name => entry["fields"]["last_name"],
        :email => entry["fields"]["email"]}
      passfields = entry["fields"]["password"].split '$'
      person[:crypted_password] = passfields[2]
      person[:password_salt] = passfields[1]
      people[entry["pk"]] = person
    end
  end
end
File.open('info.json', 'r') do |f|
  t = f.read
  obj = JSON::load t
  obj.each do |line|
    if line["model"] == "info.position"
      positions[line["pk"]] = line["fields"]["short_name"]
    end
    if line["model"] == "info.officership"
      pid = line["fields"]["person"]
      people[pid][:committeeships] ||= []
      people[pid][:committeeships] << {
        :committee => positions[line["fields"]["position"]],
        :title => 'officer', :semester => line["fields"]["semester"] }
    end
    if line["model"] == "info.extendedinfo"
      pid = line["pk"]
      people[pid][:aim] = line["fields"]["aim_sn"]
    end
  end
end
people.each do |k, v|
  p k
  p v
end
p positions
