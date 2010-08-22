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

  validates_uniqueness_of :block_id, :scope => :person_id, :message => "has already been signed up for."

  TRANSPORT_ENUM = [
    [ 'I need a ride', -1 ],
    [ "Don't worry about me", 0 ],
    [ 'I have a small sedan (4 seats)', 3 ],
    [ 'I have a sedan (5 seats)', 4 ],
    [ 'I have a minivan (7 seats)', 6 ],
  ]

end
