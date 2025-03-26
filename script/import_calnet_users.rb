lines = IO.readlines("professors.txt")
lines.each do |line|
  if line.length < 2
    break
  end
  parts = line.strip.split(',')
  uid = parts[0]
  name = parts[1]
  p = CalnetUser.new(uid: uid, name: name, authorized_course_surveys: true)
  p.save
end

