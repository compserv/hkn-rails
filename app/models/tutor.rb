class Tutor < ActiveRecord::Base

  # === List of columns ===
  #   id              : integer 
  #   person_id       : integer 
  #   availability_id : integer 
  #   languages       : string 
  #   created_at      : datetime 
  #   updated_at      : datetime 
  # =======================

  belongs_to :person

  validates :person, :presence => true

  has_many :courses
  has_many :slots
  has_one :availability
end
