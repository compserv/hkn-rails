namespace :tutoring do
  namespace :availabilities do
    AvailabilityFields = [:preferred_room, :preference_level, :time, :room_strength] 
    CoursePrefFields   = [:level]
    FieldSeparator = ';'

    ##########
    # EXPORT #
    ##########
    desc "Exports availabilities linked to username, for portability to other machines."
    task :export, :filename do |t, args|
      args.with_defaults :filename => Time.now.strftime('Availabilities__%Y_%m_%d__%k_%M_%S.txt')
      filename = args[:filename]
      puts "Exporting availabilities to #{filename}..."

      data = {}

      Tutor.all.each do |tooter|
        next if tooter.availabilities.empty?
        
        tHash = {}

        tHash[:availabilities] = tooter.availabilities.collect do |avail|
          h = {}
          AvailabilityFields.each {|field| h[field] = avail.send(field) }
          h
        end

        tHash[:courseprefs] = tooter.course_preferences.collect do |cp|
          {:level => cp.level, :coursename => "#{cp.course.dept_abbr} #{cp.course.full_course_number}"} 
        end

        data[tooter.person.username] = tHash 
      end

      File.open(filename, "w") do |f|
        f.write "# Availabilities dump #{Time.now}\n\n"
        f.write YAML::dump(data)
      end # file
    end # export

    ##########
    # IMPORT #
    ##########
    desc "Imports availabilities from a file created by :export."
    task :import, :filename do |t, args|
      ActiveRecord::Base.transaction do
      raise "Please provide a filename to import from." if args[:filename].blank?

      y = {}

      File.open(args[:filename], "r") do |f|
        y = YAML::load(f)
      end
      
      puts "Found #{y.length} tutors."

      y.each_pair do |username, data|
        p = Person.find_by_username(username)
        if p.nil? then
          puts "WARNING: Couldn't find user #{username}"
          next
        end
        
        t = p.get_tutor
        puts "#{username}:", " #{data[:availabilities].length} availabilities"

        data[:availabilities].each do |avail|
          avail[:tutor_id] = t.id

          if Availability.exists?(:tutor_id => t.id, :time => avail[:time]) then
            puts "  Skipping existing #{avail[:time].localtime.strftime('%a %I%P')}"
            next 
          end

          puts "  #{avail[:time].localtime.strftime('%a %I%P')}"
          new_a = Availability.create(avail)
          puts "  #{new_a.inspect}: #{new_a.errors}" unless new_a.save
        end

        puts " #{data[:courseprefs].length} course prefs"

        data[:courseprefs].each do |cp|
          args = cp[:coursename].split
          c = Course.lookup_by_short_name(args[0], args[1])
          puts "WARNING: unknown course #{cp[:coursename]}" and next if c.nil?

          cp[:tutor_id]  = t.id
          cp[:course_id] = c.id

          if CoursePreference.exists?(:tutor_id => t.id, :course_id => c.id) then
            puts "  Skipping existing #{c.course_abbr}"
            next
          end

          cp.delete(:coursename)

          puts "  #{c.course_abbr}"
          new_cp = CoursePreference.create(cp)
          puts "  #{new_cp.inspect}: #{new_cp.errors}" unless new_cp.save
        end
      end

      end #transaction
    end # import

  end # availabilities
end # tutoring


# Idea for args taken from
# http://www.viget.com/extend/protip-passing-parameters-to-your-rake-tasks/
