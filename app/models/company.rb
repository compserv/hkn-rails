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
  has_many  :transactions
  validates_presence_of :name

  acts_as_authentic do |config|
    config.login_field = :name
  end

  scope :ordered, -> { order('name ASC') }
  
  def to_s
    name
  end
end
