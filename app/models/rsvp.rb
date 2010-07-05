class Rsvp < ActiveRecord::Base

  # === List of columns ===
  #   id              : integer 
  #   confirmed       : string 
  #   confirm_comment : text 
  #   person_id       : integer 
  #   event_id        : integer 
  #   comment         : text 
  #   transportation  : integer 
  #   created_at      : datetime 
  #   updated_at      : datetime 
  #   block_id        : integer 
  # =======================

  belongs_to :person
  belongs_to :event
  belongs_to :block

  validates :person, :presence => true
  validates :event, :presence => true
  validates :block, :presence => true
end
