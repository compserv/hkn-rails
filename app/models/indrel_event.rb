class IndrelEvent < ActiveRecord::Base

  # === List of columns ===
  #   id                   : integer 
  #   time                 : datetime 
  #   location_id          : integer 
  #   indrel_event_type_id : integer 
  #   food                 : text 
  #   prizes               : text 
  #   turnout              : integer 
  #   company_id           : integer 
  #   contact_id           : integer 
  #   officer              : string 
  #   feedback             : text 
  #   comments             : text 
  #   created_at           : datetime 
  #   updated_at           : datetime 
  # =======================

  belongs_to :location
  belongs_to :indrel_event_type
  belongs_to :company
  belongs_to :contact

  def to_s
    "#{company} #{indel_event_type}"
  end
end
