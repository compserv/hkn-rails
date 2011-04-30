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
  # =======================

  belongs_to :person

  validates_uniqueness_of   :person_id, :scope => :semester
  validates_presence_of     :person_id, :position
  #validates_numericality_of :sid, :keycard, :on => :update
  validates_associated      :person
  validates_each            :position do |model, attr, value|
      model.errors.add(attr, 'must be a committee') unless Group.committees.exists?(:name => value)
  end

  scope :current_semester, lambda { where(:semester => Property.current_semester) }

  before_create :set_current

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
    self.elected_time = Time.now
    self.semester = Property.current_semester
  end

end

