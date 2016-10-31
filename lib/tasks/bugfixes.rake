namespace :bugfix do

  desc 'Finds all Instructors who have both taught and TA\'d, and sets their titles to Student Instructor.'
  task :student_instructorize do
    studinsts = []
    puts "Looking..."
    Instructor.all.each do |i|
      studinsts << i if i.instructorships.exists?(ta: true) && i.instructorships.exists?(ta: false)
    end

    studinsts = studinsts.collect {|i| [true, i]}

    while true do
      system 'clear'
      # Output list of studs
      puts "Student instructors:     (* means mark for update)"
      studinsts.each_with_index {|s,i| puts "#{i.to_s.rjust(3)}. #{s[0] ? '*' : ' '} #{s[1].full_name}"}

      puts "Enter a number to mark/unmark, or 'ok' to continue, or 'quit' to cancel:"

      cmd = STDIN.readline.strip
      case
      when cmd =~ /\d+/ then studinsts[cmd.to_i][0] = !studinsts[cmd.to_i][0]
      when cmd =~ /ok/i then break
      when cmd =~ /quit/i then raise "User aborted"
      else puts 'Unknown command.'
      end # case

    end # loop

    # Update
    studinsts.each do |b, s|
      next unless b
      s.update_attribute :title, 'Student Instructor'
    end

    studinsts.each {|b,s| puts "#{s.full_name.ljust(25)} #{s.title}"}

  end

end # bugfix
