namespace :tutoring do
  namespace :availabilities do
    AvailabilityFields = [:preferred_room, :preference_level, :time, :room_strength] 
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

        data[tooter.person.username] = tooter.availabilities.collect do |avail|
          h = {}
          AvailabilityFields.each {|field| h[field.to_s] = avail.send(field) }
          h
        end
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
      raise "Please provide a filename to import from." if args[:filename].blank?

      y = {}

      File.open(args[:filename], "r") do |f|
        y = YAML::load(f)
      end
      
      puts "Found #{y.length} tutors."

      y.each_pair do |username, avails|
        p = Person.find_by_username(username)
        if p.nil? then
          puts "WARNING: Couldn't find user #{username}"
          next
        end
        
        t = p.get_tutor
        puts "#{username}: #{avails.length} availabilities"

        # Convert keys from str => symbol
        avails.each do |avail_with_str|
          avail = {}
          avail_with_str.each_pair do |k, v|
            avail[k.to_sym] = v
          end

          next if Availability.exists?(:tutor_id => t.id, :time => avail[:time])
          new_a = Availability.create(avail.merge :tutor_id => t.id)
          puts "  #{new_a.inspect} -- #{new_a.save}: #{new_a.errors}"
        end
      end

    end # import

  end # availabilities
end # tutoring


# Idea for args taken from
# http://www.viget.com/extend/protip-passing-parameters-to-your-rake-tasks/
