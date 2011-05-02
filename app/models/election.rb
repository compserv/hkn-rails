class Election < ActiveRecord::Base

  # === List of columns ===
  #   id               : integer 
  #   person_id        : integer 
  #   position         : string 
  #   sid              : integer 
  #   keycard          : integer 
  #   midnight_meeting : boolean 
  #   txt              : boolean 
  #   semester         : string 
  #   elected_time     : datetime 
  #   created_at       : datetime 
  #   updated_at       : datetime 
  #   elected          : boolean 
  #   non_hkn_email    : string 
  #   desired_username : string 
  # =======================

  belongs_to :person

  validates_uniqueness_of   :person_id, :scope => [:position, :semester]
  validates_presence_of     :person_id, :position, :semester
  #validates_numericality_of :sid, :keycard, :on => :update
  validates_associated      :person
  validates_each            :position do |model, attr, value|
      model.errors.add(attr, 'must be a committee') unless Group.committees.exists?(:name => value)
  end

  scope :current_semester, lambda { where(:semester => Property.current_semester) }
  scope :ordered, lambda { order(:elected_time) }
  scope :elected, lambda { where(:elected => true) }

  before_validation :set_current

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
  #  - Run hknmod.py to put person on mailing lists
  #
  def commit
    return false unless self.elected

    # group management
    person.groups = person.groups | [Group.find_by_name("officers"), Group.find_by_name("comms"),Group.find_by_name(self.position)]

    # username changes
    person.username = self.final_username
    return false unless person.valid? && person.save

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

    Rails.logger.info "Election Create: #{self.inspect} #{self.person.inspect} 'hknmod #{cmd.join ' '}'"
    Rails.logger.info `./run_hknmod #{cmd.join ' '}`
    #Rails.logger.info system('./run_hknmod', *cmd)
  end

#  def method_missing_with_person(sym, *args, &block)
#    method_missing_without_person(sym, *args, &block) rescue self.person.send(sym, *args, &block) 
#  end
#
#  alias_method_chain :method_missing, :person

  # FIXME: idk how to do this. alias_method_chaining method_missing didn't work...
#  [:username, :phone_number, :aim, :email, :local_address, :date_of_birth].each do |meth|
#      attr_accessible meth
#      define_method meth do
#          person.send meth
#      end
#      define_method "#{meth}=" do |rhs|
#          person.send "#{meth}=", rhs
#      end
#  end

private

  def set_current
    self.elected_time ||= Time.now
    self.semester ||= Property.current_semester
  end

end

