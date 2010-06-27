class Contact < ActiveRecord::Base

  # === List of columns ===
  #   id         : integer 
  #   name       : string 
  #   email      : string 
  #   phone      : string 
  #   created_at : datetime 
  #   updated_at : datetime 
  #   company_id : integer 
  #   comments   : text 
  #   cellphone  : string 
  # =======================

  belongs_to  :company
  validates_presence_of :name, :email

  def to_s
    name
  end
end
