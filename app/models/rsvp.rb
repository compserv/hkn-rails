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

  TRANSPORT_ENUM = [
    [ 'I need a ride', -1 ],
    [ "Don't worry about me", 0 ],
    [ 'I have a small sedan (4 seats)', 3 ],
    [ 'I have a sedan (5 seats)', 4 ],
    [ 'I have a minivan (7 seats)', 6 ],
  ]

  Confirmed   = 't'
  Unconfirmed = 'f'
  Rejected    = 'r'

  belongs_to :person
  belongs_to :event
  has_and_belongs_to_many :blocks

  validates :person, :presence => true
  validates :event, :presence => true

  validates_inclusion_of :confirmed, :in => [Confirmed, Unconfirmed, Rejected, nil]

  validate :at_least_one_block

  validates_uniqueness_of :event_id, :scope => :person_id, :message => "has already been signed up for."

  before_validation :set_default_transportation

  scope :confirmed, where("confirmed = ?", "t")
  scope :ordered, joins(:event).order('events.start_time ASC')
  scope :ordered_desc, joins(:event).order('events.start_time DESC')

  attr_accessible :comment, :transportation

  def at_least_one_block
    unless blocks.size >= 1
      errors[:blocks] << "must include at least one block"
    end
  end

  def need_transportation
    event and event.need_transportation
  end

private

  def set_default_transportation
    if self.need_transportation
      self.transportation ||= TRANSPORT_ENUM.first.last
    end
  end

end
