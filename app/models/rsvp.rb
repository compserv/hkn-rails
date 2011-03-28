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
  # =======================

  belongs_to :person
  belongs_to :event
  has_and_belongs_to_many :blocks

  validates :person, :presence => true
  validates :event, :presence => true
  validate :at_least_one_block

  validates_uniqueness_of :event_id, :scope => :person_id, :message => "has already been signed up for."

  scope :confirmed, where("confirmed = ?", "t")
  scope :ordered, joins(:event).order('events.start_time ASC')
  scope :ordered_desc, joins(:event).order('events.start_time DESC')

  TRANSPORT_ENUM = [
    [ 'I need a ride', -1 ],
    [ "Don't worry about me", 0 ],
    [ 'I have a small sedan (4 seats)', 3 ],
    [ 'I have a sedan (5 seats)', 4 ],
    [ 'I have a minivan (7 seats)', 6 ],
  ]

  def at_least_one_block
    unless blocks.size >= 1
      errors[:blocks] << "must include at least one block"
    end
  end

end
