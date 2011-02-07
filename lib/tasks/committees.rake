namespace :committees do
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

end # committees
