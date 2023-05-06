# == Schema Information
#
# Table name: committeeships
#
#  id         :integer          not null, primary key
#  committee  :string(255)
#  semester   :string(255)
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  person_id  :integer
#

class Committeeship < ActiveRecord::Base
  @Committees = %w(pres vp evp ivp rsec treas csec deprel alumrel opsec act bridge compserv decal indrel serv studrel tutoring pub examfiles ejc prodev)	#This generates a constant which is an array of possible committees.
  Semester = /\A\d{4}[0-4]\z/                  # A regex which validates the semester
  Positions = %w(officer assistant cmember candidate)  # A list of possible positions
  Execs = %w(pres vp evp ivp rsec csec treas deprel alumrel opsec) # Executive positions
  NonExecs = @Committees - Execs

  validates_presence_of :person_id
  validates_format_of :semester, with: Semester, message: "Not a valid semester."
  validates_inclusion_of :title, in: Positions, message: "Not a valid title."
  validates_inclusion_of :committee, in: @Committees, message: "Committee not recognized."
  validates_uniqueness_of :committee, scope: [:person_id, :semester]

  belongs_to :person

  after_create :assign_groups

  # We have this argumentless lambda because we don't want to evaluate
  # Property.semester until we call the scope, not when we define it
  scope :current,      -> { where(semester: Property.semester) }
  scope :next,         lambda { where(semester: Property.next_semester) }
  scope :semester,     lambda { |s| where(semester: s) }
  scope :committee,    lambda { |x| where(committee: x) }
  scope :officers,     -> { where(title: "officer") }
  scope :all_officers, -> { where(title: ["officer", "assistant"]) }
  scope :assistants,   -> { where(title: "assistant") }
  scope :cmembers,     -> { where(title: "cmember") }
  scope :candidates,   -> { where(title: "candidate") }

  class << self
    attr_reader :Committees, :Positions
  end

  SEMESTER_MAP = { 1 => "Spring", 2 => "Summer", 3 => "Fall" }

  def exec?
    Execs.include? self.committee
  end

  def nice_semester
    "#{SEMESTER_MAP[semester[-1..-1].to_i]} #{semester[0..3]}"
  end

  def nice_position
    execs = %w[pres vp rsec treas csec]
    if execs.include? committee
      nice_committee
    else
      "#{nice_committee} #{nice_title}"
    end
  end

  def nice_title
    nice_titles = {
      "officer"   => "Officer",
      "assistant" => "Assistant Officer",
      "cmember"   => "Committee Member",
      "candidate" => "Candidate"
    }
    nice_titles[title]
  end

  def nice_committee
    nice_committees = {
      "pres"     => "President",
      "ivp"       => "Internal Vice President",
      "evp"       => "External Vice President",
      "vp"       => "Vice President",
      "rsec"     => "Recording Secretary",
      "csec"     => "Corresponding Secretary",
      "opsec"    => "Operations Secretary",
      "treas"    => "Treasurer",
      "deprel"   => "Department Relations",
      "act"      => "Activities",
      "alumrel"  => "Alumni Relations",
      "bridge"   => "Bridge",
      "compserv" => "Computing Services",
      "decal"    => "Decal",
      "indrel"   => "Industrial Relations",
      "serv"     => "Service",
      "studrel"  => "Student Relations",
      "tutoring" => "Tutoring",
      "pub"      => "Publicity",
      "examfiles"=> "Exam Files",
      "prodev"   => "Professional Development"
    }
    nice_committees[committee]
  end


  private

  def assign_groups
    # Adds the associated person to:
    #   candplus     always
    #
    #   comms        if officer or cmember
    #
    #   officers     depending on the title
    #   cmembers
    #   candidates
    #
    # Does not save the group changes. You have to do that yourself.
    #

    # TODO: this is duplicating work... we could implement in-group as
    # person.committeeships.exists? ...

    grups = ['candplus']

    # Don't add candidates to groups
    # TODO: is this right?
    grups << self.committee << 'comms' unless self.title == 'candidate'

    # officers, cmembers, candidates
    grups << self.title.pluralize

    self.person.join_groups grups
  end
end
