class ElectionObserver < ActiveRecord::Observer
  observe :election

  def after_create(election)
    person = election.person

    # Logging info
    log election, :create

    # Add person to comms
    person.groups ||= [Group.find_by_name("comms")]

    # hknmod
    cmd = []
    cmd << "-l #{person.username}"
    cmd << "-c #{election.position}"
    if election.first_election?
      cmd << "-a"
      cmd << "-n #{person.full_name.inspect}"
      cmd << "-e #{person.email.inspect}"
    else # returning officer
      cmd << "-m"
    end

    Rails.logger.info "Election Create: #{election.inspect} #{person.inspect} 'hknmod #{cmd.join ' '}'"
    system 'hknmod', *cmd
  end

  def after_update(election)
    log election, :update
  end

  def after_destroy(election)
    log election, :destroy
  end

  private

  def log(election, event=:create)
    logfile = "log/elections_#{Property.current_semester}.log"

    File.open logfile, 'a+' do |f|
      # write header if this is a new file
      unless f.stat.size?
          i = 0
          f << ['Event', 'position', 'person', 'time', 'data'].join('         ')
          f << "\n"
      end

      # data for this election
      fields = [election.position, election.person.full_name, election.elected_time]
      fwidth = [20,                25,                        25]

      fields = fields.collect(&:to_s).collect(&:inspect).collect {|s| s.ljust fwidth.shift}
      fields << ActiveSupport::JSON.decode(election.to_json).merge({:person => {:username => election.person.username}}).to_json

      # get event name
      eventName = {:create  => 'NewElection',
                   :update  => 'UpdateElection',
                   :destroy => 'DestroyElection'
                  } [event]

      f << "#{eventName}: #{fields.join ', '}"
      f << "\n"
    end
  end

end

