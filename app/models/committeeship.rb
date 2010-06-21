class Committeeship < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   committee  : string 
  #   semester   : string 
  #   title      : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   person_id  : integer 
  # =======================

  Committees = %w(president vp rsec treas csec deprel act alumrel bridge compserv indrel serv studrel tutoring)	#This generates a constant which is an array of possible committees.
  Semester = /(fa|sp)\d{2,2}/	#A regex which validates the semester
  Positions = %w(officer cmember candidate)	#A list of possible positions
  validates_inclusion_of :committee, :in => Committees, :message => "Committee not recognized."
  validates_format_of :semester, :with => Semester, :message => "Not a valid semester."
  validates_inclusion_of :title, :in => Positions, :message => "Not a valid title." 
  
  belongs_to :person
end
