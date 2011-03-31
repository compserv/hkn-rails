class DeptTourRequest < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   date       : datetime 
  #   submitted  : datetime 
  #   contact    : string 
  #   phone      : string 
  #   comments   : text 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   responded  : boolean 
  # =======================

  
  validates_presence_of :name
  validates_presence_of :date
  validates_presence_of :submitted
  validates_presence_of :contact
  validates_inclusion_of :responded, :in =>[true,false]

end
