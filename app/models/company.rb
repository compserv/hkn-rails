class Company < ActiveRecord::Base

  # === List of columns ===
  #   id                  : integer 
  #   name                : string 
  #   address             : text 
  #   website             : string 
  #   created_at          : datetime 
  #   updated_at          : datetime 
  #   comments            : text 
  #   persistence_token   : string 
  #   single_access_token : string 
  # =======================

  has_many  :contacts
  validates_presence_of :name

  acts_as_authentic

  scope :ordered, -> { order('name ASC') }
  
  def to_s
    name
  end
end
