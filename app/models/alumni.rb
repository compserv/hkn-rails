class Alumni < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   grad_semester : string 
  #   grad_school   : string 
  #   job_title     : string 
  #   company       : string 
  #   salary        : integer 
  #   person_id     : integer 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  # =======================

  belongs_to :person
  validates_uniqueness_of :person_id
  validates_inclusion_of :salary, :in => 0...5000000000000000000, :message=>"must be within 0 and 5 quintillion", :allow_nil=>true
end
