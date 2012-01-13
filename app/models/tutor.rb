class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   person_id  : integer 
  #   languages  : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   adjacency  : integer 
  # =======================

  belongs_to :person

  has_many :course_preferences, :dependent => :destroy
  has_many :courses, :through => :course_preferences, :uniq => true
  has_and_belongs_to_many :slots
  has_many :availabilities

  validates :person, :presence => true

  # A current tutor has an {Election} for the current semester,
  # as given by {Property.current_semester}.
  # Also sorts by [{Person.first_name first_name}, {Person.last_name last_name}].
  scope :current, lambda { self.current_scope_helper.order(:first_name,:last_name) }

  class << self
    # This has been separated out like this in order to apply the scope when 
    # using Tutor as an association.
    # In other words, if we want all Availabilities from Tutors who are current,
    # we write Tutor.current_scope_helper(Availabilities, :tutor).
    def current_scope_helper(query=self, join_name=nil)
      join = {:person => :elections}
      join = {join_name => join} unless query == self
      query.joins(join).where(:elections => {:semester => Property.current_semester, :elected => true})
    end
  end
  
  def to_s
    return person.fullname
  end
end
