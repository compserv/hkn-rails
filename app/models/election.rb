# == Schema Information
#
# Table name: elections
#
#  id               :integer          not null, primary key
#  person_id        :integer          not null
#  position         :string(255)
#  sid              :integer
#  keycard          :integer
#  midnight_meeting :boolean          default(TRUE)
#  txt              :boolean          default(FALSE)
#  semester         :string(255)      not null
#  elected_time     :datetime         not null
#  created_at       :datetime
#  updated_at       :datetime
#  elected          :boolean          default(FALSE), not null
#  non_hkn_email    :string(255)
#  desired_username :string(255)
#

class Election < ActiveRecord::Base
  belongs_to :person

  validates_uniqueness_of   :person_id, scope: [:position, :semester]
  validates_presence_of     :person_id, :position, :semester
  validates                 :keycard, numericality: {
    greater_than_or_equal_to: 10000,
    less_than_or_equal_to:    999999,
    message:                  "must be a 5- or 6-digit number",
    allow_nil:                true
  }
  validates                 :sid, numericality: { allow_nil: true }
  validates_associated      :person
  validates_each            :position do |model, attr, value|
    model.errors.add(attr, 'must be a committee') unless Group.committees.exists?(name: value)
  end

  scope :current_semester, lambda { where(semester: Property.next_semester) }
  scope :ordered, lambda { order(:elected_time) }
  scope :elected, lambda { where(elected: true) }

  before_validation :set_current

  OutputFile = "./elections_hknmod"

  def self.semester
    Property.next_semester
  end

  def self.begin
    File.open(OutputFile, 'w') do |f|   # yes, overwrite contents
      f.puts "# Elections for #{Property.pretty_semester Election.semester}"
    end
  end

  def self.end
    # nothing to do yet
  end

  def filled_out?
    [sid, keycard, non_hkn_email].none? { |x| x.blank? }
  end

  # Is this the person's first officership?
  def first_election?
    # hacky heuristic.. if they're on a committee already, assume no
    return false unless (self.person.groups & Group.committees).empty?
    return false if self.person.elections.count > 1
    return true
  end

  # Determines the person's final username:
  # If they've specified a different one, return this preferred uname,
  # else return existing one
  #
  def final_username
    self.desired_username.present? && self.desired_username != self.person.username ? self.desired_username : self.person.username
  end

  # Commits changes represented by this Election:
  #  - Add person to comms, officers, and corresponding committee
  #  - Create committeeship
  #  - Run hknmod.py to put person on mailing lists and create accounts
  #
  def commit
    return false unless self.elected

    # group management
#    person.groups = person.groups | [Group.find_by_name("officers"), Group.find_by_name("comms"),Group.find_by_name(self.position)]
    # TODO: Support adding assistant officers too
    cship = Committeeship.create({
        person_id: self.person_id,
        committee: self.position,
        semester:  self.semester,
        title:     'officer'
    })

    # username changes
    person.username = self.final_username
    unless person.valid? && person.save && person.reload && self.reload
      Rails.logger.error "Failed to apply username change #{person.username_was} -> #{self.final_username}"
      return false
    end

    # ensure s/he has a tutor
    unless self.person.get_tutor
      Rails.logger.error "Failed to create tutor for #{person.username}"
      return false
    end

    # hknmod
    cmd = []
    cmd << "-s"
    cmd << "-l #{self.person.username}"
    cmd << "-c #{self.position}"
#    if self.first_election?
#      cmd << "-a"
      cmd << "--nf #{self.person.first_name.inspect}"
      cmd << "--nl #{self.person.last_name.inspect}"
      cmd << "-e #{self.person.email.inspect}"
#    else # returning officer
#      cmd << "-m"
#    end

    hknmod_cmd = "./run_hknmod #{cmd.join ' '}"

    Rails.logger.info "Election Create: #{self.inspect} #{self.person.inspect}: #{hknmod_cmd}"
    #Rails.logger.info `./run_hknmod #{cmd.join ' '}`
    #Rails.logger.info system('./run_hknmod', *cmd)

    # Write into log file rather than directly hknmodding
    File.open(OutputFile, 'a') do |f|
      f.puts hknmod_cmd
    end

    return true
  end

  private

  def set_current
    self.elected_time ||= Time.now
    self.semester ||= Property.next_semester #current_semester
  end
end
