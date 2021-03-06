class ElectionObserver < ActiveRecord::Observer
  observe :election

  def before_update(election)
    person = election.person

    return true unless election.elected   # don't care about candidates

    if election.elected_was == false then # new election
        # Logging info
        log election, :create

    elsif election.changed? # just an update..
        log election, :update
    end

    return true
  end

#  def after_update(election)
#    # only log elected people, not candidates
#    if election.elected_was == false && election.elected then
#        log election, :update
#    end
#  end

  def after_destroy(election)
    if election.elected
        log election, :destroy
    end
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
      fields << ActiveSupport::JSON.decode(election.to_json).merge({person: {username: election.person.username}}).to_json

      # get event name
      eventName = {create:  'NewElection',
                   update:  'UpdateElection',
                   destroy: 'DestroyElection'
                  } [event]

      f << "#{eventName}: #{fields.join ', '}"
      f << "\n"
    end
  end
end
