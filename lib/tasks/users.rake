namespace :users do
  desc "Populates picture URLs from hkn.eecs.berkeley.edu/files/officerpics"
  task :populate_pics do
    require 'open-uri'

    Person.all.each do |p|
      pic = p.picture(false)
      puts "#{p.username}: #{pic}"

      if pic.blank?
          pic = p.picture(true)
          puts "  Guessing #{pic}"
      end

      # Make sure it really exists
      begin
       open pic
       p.update_attribute(:picture, pic) unless pic.eql?(p.picture(false))
      rescue => e
        puts "  ^ Does not exist. (#{e})"
        p.update_attribute(:picture, nil)
        next
      end
    end # Person.all
  end # populate_pics

  desc "Maps names to email addies. Usage: names_to_emails[\"optional format string containing 'name' and/or 'email'\"]"
  task :names_to_emails, :fmt do |t,args|
    puts "ARGS: #{args.inspect}!"
    fmt = args[:fmt] || "\"name\" = email"

    puts "Gimme some names, one per line, with CTRL+D at the end:"
    stuff = {success: [], multiple: [], none: []}

    $stdin.readlines.collect(&:strip).each do |name|
      next if name.blank?

      # Split and search name
      fname = name.split
      lname = fname.pop
      fname = fname.join ' '
      p = Person.where("(\"people\".\"first_name\"||\"people\".\"last_name\") LIKE '%#{fname}%#{lname}%'").select(:email)

      # Put results in some bucket
      if p.length > 1 then
        stuff[:multiple] << "#{name}: #{p.collect(&:email).inspect}"
      elsif p.length == 1 then
        # stuff[:success] << "\"#{name}\" = #{p.first.email}"
        s = fmt.dup
        [['name',name],['email',p.first.email]].each {|f,v| s.gsub! f,v}
        stuff[:success] << s
      else
        stuff[:none] << "#{name}"
      end
    end

    puts "kthx.\n\n"

    stuff.each_pair do |cat,strs|
      puts "-"*80
      puts "#{cat.to_s.capitalize}:"
      strs.each {|s| puts s}
    end

  end # names_to_emails

end # users
