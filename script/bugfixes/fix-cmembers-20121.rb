require File.expand_path(File.join('..', '..', 'config', 'environment'), File.dirname(__FILE__))

Renames = {
  :p1harvey     => :pharvey,
  :smakhani     => :samir,
  'edliao.9.16' => :edliao,
  :fishcube     => :jl,
  'xiao.allen'  => :allenxiao,
  :sorry        => :sungroa,
  :gramnarayan  => :govind,
  :stvnrhodes   => :steven,
  :krnshadow65  => :jyoshim
}

NeedAccounts = [
  'Fang-Kwei Chang',
  'Amrit Kashyap',
  'He Ma',
  'Katrina Chang'
]

Committeeships = {
  :act        => [ :steven, :jyoshim ],
  :bridge     => [ :ystephie, :daiweili, :mmurthy ],
  :compserv   => [ :hbradlow, :omarali, :twang, :pharvey, :mniknami, :azhai, :samir ],
  :serv       => [ :roberttk ],
  :studrel    => [ :solomonwang ],
  :tutoring   => [ :brandonwang, :edliao, :heerad, :jl, :jkotker, :allenxiao, :sungroa, :clee, :govind, :markrogersjr ]
}

def debug(*args)
  puts *args
  File.open( __FILE__.gsub(/\.rb$/, '.log'), 'a' ) {|f| f.write "#{args.join("\n")}\n"}
end

def main
  debug "\n", Time.now.to_s.rjust(80,'-') #'-'*80
  debug "The following people do not have accounts:", NeedAccounts.collect{|n| "  #{n}"}

  debug "=== Renames ==="
  Renames.each_pair do |old_username, new_username|
    old_username, new_username = old_username.to_s, new_username.to_s
    debug "#{old_username.ljust 15} => #{new_username}"
    # puts "hi -eric"

    if !Person.exists?(:username => old_username) or Person.exists?(:username => new_username)
      raise StandardError, "username already taken: #{new_username}"
    end

    p = Person.find_by_username(old_username)
    unless p.update_attribute(:username, new_username)
      raise StandardError, p.errors.inspect #p.errors.messages.inspect
    end

  end

  debug "=== Committeeships ==="
  comms = Group.find_by_name('comms')
  Committeeships.each_pair do |committee, users|
    users.each do |username|
      username, comm = username.to_s, committee.to_s
      debug "#{username.ljust 15} -> #{committee}"

      unless p = Person.find_by_username(username)
        raise StandardError, "unknown user: #{username}"
      end

      unless g = Group.find_by_name(comm)
        raise StandardError, "unknown group: #{comm}"
      end

      if c = p.committeeships.current.first
        raise StandardError, "committeeship already exists: #{c}"
      end

      c = Committeeship.new(:committee => comm, :person => p, :semester => Property.current_semester, :title => 'cmember')
      unless c.save
        raise StandardError, "cship invalid: #{c.errors.inspect}"
      end

      p.groups |= [g, comms]
      unless p.save
        raise StandardError, "failed to update groups: #{p.errors.inspect}"
      end

    end
  end
end

def verify
  Committeeships.each_pair do |committee, usernames|
    usernames.each do |username|
      raise(StandardError, "verification failed #{committee} #{username}") unless Group.find_by_name(committee).people.include?(Person.find_by_username(username))
    end
  end
end

if $0 == __FILE__
  Person.transaction do
    begin
      main
      verify
    rescue => e
      debug "\n***FAIL: #{e.message}"
      raise
    end
  end
end
