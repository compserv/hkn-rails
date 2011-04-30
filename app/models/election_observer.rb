class ElectionObserver < ActiveRecord::Observer
  observe :election

  def after_create(election)
    person = election.person

    # Logging info
    log election

    # Add person to comms
    person.groups |= [Group.find_by_name("comms")]
  end

  private

  def log(election)
    # TODO: write me
    puts "ElectionObserver.log: implement me!"
  end

end

